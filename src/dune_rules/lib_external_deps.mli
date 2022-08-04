open Import

module Kind :sig
  type t =
    | Required
    | Optional
end

val add : Lib_name.t -> unit
val set : Lib_name.t -> Context_name.t * Path.Build.t * Kind.t -> unit
val print : unit -> Stdune.User_message.t
val sexp  : unit -> Stdune.User_message.t
