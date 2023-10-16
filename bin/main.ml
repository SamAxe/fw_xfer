open Ppx_yojson_conv_lib.Yojson_conv.Primitives

let fetch_and_save_page 
  ~( hosturi : Uri.t ) 
  ~( directory : string ) 
  ~( rel_url_prefix : string ) 
  ~( save_name : string ) 
  ~( page : string ) =
  Fw_xfer.create_newdir directory ;
  let page_url = rel_url_prefix ^ page in
    print_endline @@ "getting '" ^ (Uri.to_string hosturi) ^ "'    " ^ page_url ;
    let host_uri = Uri.with_path hosturi page_url in
    let page_content = Lwt_main.run @@ Fw_xfer.get_page host_uri in

    let page_file_name = Filename.basename page in
    let out_filename = directory ^ 
      if save_name = ""
      then page_file_name 
      else save_name
    in
      let oc = open_out_bin out_filename in
        Stdlib.output_string oc page_content;
        close_out oc

type slug_name = string [@@deriving yojson]
type slugs     = slug_name list [@@deriving yojson]

type asset_entry = 
  { file : string
  ; size : int 
  }
  [@@deriving yojson]

type assets = asset_entry list [@@deriving yojson]

let () =

  if (Array.length Sys.argv) <> 2
  then failwith "Usage: fw_xfer <hosturi>"
  else

  let hosturi = Uri.of_string Sys.argv.(1) in

(*   1.  Download the `<old_host>/system/slugs.json` to ./slugs.json *)
  fetch_and_save_page ~hosturi:hosturi ~directory:"" ~rel_url_prefix:"system/" ~page:"slugs.json" ~save_name:"" ; 

(*   2.  Each `<slugname>` in the `slugs.json` file can be retrieved with a
         `<old_host>/<slugname>.json` request.  These files should be saved with
         as the `<slugname>`.
*)
  let in_ch     = Stdlib.open_in "slugs.json" in
  let in_length = Stdlib.in_channel_length in_ch in
  let text      = Stdlib.really_input_string in_ch in_length in

  let slug_json = Yojson.Safe.from_string text in
  let slug_list = slugs_of_yojson slug_json in
    slug_list |> List.iter ( fun slug_name -> 
      let slug_url = slug_name ^ ".json" in 
        fetch_and_save_page ~hosturi:hosturi ~directory:"pages/" ~rel_url_prefix:"" ~page:slug_url ~save_name:slug_name
      ) 
  ;

(*
4. Download the `<old_host>/plugin/assets/index` asset index file.  This returns
   an array of `<filename>`, `<size>` pairs.
*)
  fetch_and_save_page ~hosturi:hosturi ~directory:"" ~rel_url_prefix:"plugin/assets/" ~page:"index" ~save_name:"index.json" ;

(*
5. Each `<path_name>` in the asset index file can be retrieved with a 
   `<old_host>/assets/<path_name>` request.  The file needs to be saved in a 
   hierarchy that preserves the `<path_name>`.
*)

  let in_ch     = Stdlib.open_in "index.json" in
  let in_length = Stdlib.in_channel_length in_ch in
  let text      = Stdlib.really_input_string in_ch in_length in

  let asset_json = Yojson.Safe.from_string text in
  let asset_list = assets_of_yojson asset_json in
    asset_list |> List.iter ( fun entry -> 
      let asset_url = entry.file in 
        fetch_and_save_page ~hosturi:hosturi ~directory:"assets/" ~rel_url_prefix:"assets" ~page:asset_url ~save_name:""
      ) 
    ;

(*
6. It appears that `sitemap.xml` `sitemap.json` and `site-index.json` also need
   to be downloaded and updated on the new server, but this is less obvious to me.
*)

  fetch_and_save_page ~hosturi:hosturi ~directory:"" ~rel_url_prefix:"" ~page:"sitemap.xml" ~save_name:"" ;
  fetch_and_save_page ~hosturi:hosturi ~directory:"" ~rel_url_prefix:"system/" ~page:"sitemap.json" ~save_name:"" ;
  fetch_and_save_page ~hosturi:hosturi ~directory:"" ~rel_url_prefix:"system/" ~page:"site-index.json" ~save_name:"" ;
