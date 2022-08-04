open Import

module Kind = struct

  type t =
    | Required
    | Optional

  let to_dyn kind =
    match kind with
    | Required -> Dyn.String "require"
    | Optional -> Dyn.String "optional"

  let merge x y =
    match (x,y) with
    | Optional,Optional -> Optional
    | _ -> Required
end


module Table_context = Hashtbl.Make(Context_name)
module Hash_libs     = Hashtbl.Make(Lib_name)

module O = Comparable.Make (Path.Build)
module Dir_map = O.Map


let libs_by_ctx = Table_context.create 1
let libs = Hash_libs.create 1

let set_kind lib_map lib kind =
  match Lib_name.Map.find lib_map lib with
  | Some v -> Lib_name.Map.set lib_map lib (Kind.merge v kind)
  | None   -> Lib_name.Map.set lib_map lib kind

let set lib (ctx, dir, kind) =
  if Option.is_some (Hash_libs.find libs lib) then begin
    let (_dir_map, _lib_map) =
      match Table_context.find libs_by_ctx ctx with
      | Some dir_map ->
        (match Dir_map.find dir_map dir with
         | Some lib_map -> (Some dir_map, Some lib_map)
         | None -> (Some dir_map, None))
      | None -> (None, None)
    in
    match (_dir_map, _lib_map) with
    | None, None ->
      Table_context.set libs_by_ctx ctx
        (Dir_map.set Dir_map.empty dir (Lib_name.Map.set Lib_name.Map.empty lib kind))
    | Some dir_map, None ->
      Table_context.set libs_by_ctx ctx
        (Dir_map.set dir_map dir (Lib_name.Map.set Lib_name.Map.empty lib kind))
    | None, Some lib_map ->
      Table_context.set libs_by_ctx ctx
        (Dir_map.set Dir_map.empty dir (set_kind lib_map lib kind))
    | Some dir_map, Some lib_map ->
      Table_context.set libs_by_ctx ctx
        (Dir_map.set dir_map dir (set_kind lib_map lib kind))
  end

let add lib = ignore(Hash_libs.add libs lib None)

let print () =
  let pp dir_libs =
    let libs =
      Dir_map.values dir_libs
      |> (List.map ~f:(fun m -> Lib_name.Map.to_list m))
      |> List.flatten
      |> List.sort_uniq ~compare:(fun (x,_) (y,_) -> Lib_name.compare x y)
    in
    Pp.enumerate libs ~f:(fun (lib,kind) ->
      match kind with
      | Kind.Required -> Pp.textf "%s" (Lib_name.to_string lib)
      | Kind.Optional -> Pp.textf "%s (optional)" (Lib_name.to_string lib))
  in
  (User_message.make
     (Table_context.foldi libs_by_ctx ~init:[] ~f:(fun ctx dir_libs acc ->
        [ Pp.textf
            "These are the external library dependencies in the %s context"
            (Context_name.to_string ctx);
          pp dir_libs ] @ acc)))

let sexp () =
  let dyn dir_libs =
    Dir_map.to_dyn (fun libs -> Lib_name.Map.to_dyn (fun kind -> Kind.to_dyn kind) libs) dir_libs
  in
  (User_message.make
     (Table_context.foldi libs_by_ctx ~init:[] ~f:(fun ctx dir_libs acc ->
        [(Sexp.pp
            (List
               [ Atom (Context_name.to_string ctx); Sexp.of_dyn (dyn dir_libs)] ));
        ] @ acc)))
