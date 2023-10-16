open Lwt
open Cohttp
open Cohttp_lwt_unix
(* open Ppx_yojson_conv_lib.Yojson_conv.Primitives *)


(* Returns body of a message *)
let get_page (uri : Uri.t)  =
  Client.get uri >>= fun (resp, body) ->
    let code = resp |> Response.status |> Code.code_of_status in
      match code with 
      | 200 -> body |> Cohttp_lwt.Body.to_string >|= fun body -> body
      | _   -> failwith @@ Printf.sprintf "Response code: %d\n" code

let create_newdir path =
  if path = ""
  then ()
  else
  if not (Sys.file_exists path) 
  then 
    begin
    print_endline @@ "creating path '" ^ path ^ "'" ;
    Core_unix.mkdir_p path 
    end

let escape_spaces ( str : string ) : string = 
  str 
  |> Str.global_replace (Str.regexp "%") "%25"   (* THis has to be first! *)
  |> Str.global_replace (Str.regexp " ") "%20"
  |> Str.global_replace (Str.regexp "&") "%26" 
  |> Str.global_replace (Str.regexp "(") "%28" 
  |> Str.global_replace (Str.regexp ")") "%29" 


