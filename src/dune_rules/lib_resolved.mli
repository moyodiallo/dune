open Import

module Kind :sig
  type t =
    | Required
    | Optional
end

module External_libs : sig
  val add : Context_name.t -> Lib_name.t -> unit
  val set : Context_name.t -> Lib_name.t -> Kind.t -> unit
  val print : unit -> Stdune.User_message.t
  val sexp  : unit -> Stdune.User_message.t
end
