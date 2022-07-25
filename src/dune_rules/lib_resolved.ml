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

  let merge_opt x y=
    match (x,y) with
    | Some x,Some y -> Some (merge x y)
    | None, y -> y
    | x, None -> x

end

module External_libs = struct

  module Hashtbl = Hashtbl.Make(Context_name)
  module Map = Lib_name.Map

  let libs_by_ctx = Hashtbl.create 1

  let add ctx lib =
    match Hashtbl.find libs_by_ctx ctx with
    | Some libs ->
      if not(Map.mem libs lib)
      then ignore(Hashtbl.set libs_by_ctx ctx (Lib_name.Map.add_exn libs lib None))
    | None ->
      ignore(Hashtbl.add libs_by_ctx ctx (Lib_name.Map.add_exn Lib_name.Map.empty lib None))

  let set ctx lib kind =
    let f v =
      match v with
      | Some k -> Some (Kind.merge_opt k (Some (kind)))
      | None   -> None
    in
    match Hashtbl.find libs_by_ctx ctx with
    | Some libs -> ignore(Hashtbl.set libs_by_ctx ctx (Lib_name.Map.update libs lib ~f:f))
    | None      -> ()

  let filter_libs libs = Lib_name.Map.filter_map libs ~f:(fun kind ->
    match kind with
    | Some k -> Some k
    | None   -> None)

  let print () =
    let pp libs =
      let libs =
        List.sort (Lib_name.Map.to_list (filter_libs libs)) ~compare:(fun (x,_) (y,_) -> Lib_name.compare x y)
      in
      Pp.enumerate libs ~f:(fun (lib,kind) ->
        match kind with
        | Kind.Required -> Pp.textf "%s" (Lib_name.to_string lib)
        | Kind.Optional -> Pp.textf "%s (optional)" (Lib_name.to_string lib))
    in
    (User_message.make
       (Hashtbl.foldi libs_by_ctx ~init:[] ~f:(fun ctx libs acc ->
          [ Pp.textf
              "These are the external library dependencies in the %s context"
              (Context_name.to_string ctx);
            pp libs ] @ acc)))

  let sexp () =
    let dyn libs = Lib_name.Map.to_dyn (fun kind -> Kind.to_dyn kind) libs in
    (User_message.make
       (Hashtbl.foldi libs_by_ctx ~init:[] ~f:(fun ctx libs acc ->
          [(Sexp.pp
              (List
                 [ Atom (Context_name.to_string ctx); Sexp.of_dyn (dyn (filter_libs libs))] ));
          ] @ acc)))
end
