open Test_framework
open Comblexer
open Lcombinators.GenericParsing
open Lcombinators.CharParsing

let stub = Test("Implemented", (fun () -> false)  )
  
(* Function: Tests two tokens for equality *)
let token_eq (t1: token) (t2: token) : bool =
    match (t1, t2) with
        | (Id(v1),Id(v2)) -> (v1 == v2)
        | (Int(v1),Int(v2)) -> (v1 == v2)
        | (_,_) -> (t1 == t2)
 
let lex_test_inputs = [
    (['f';'o';'o'], [(Id "foo")]);
    (['f';'o';'o';'=';'b';'a';'z'], [(Id "foo"); Eq; (Id "baz")]);
    (['5'], [(Int 5)]);
    (['5';'+';'9'], [(Int 5);Plus;(Int 6)]);
    (['+'], [Plus]);
    (['+';' ';'f';'o';'o'], [Plus; (Id "foo")])
]

let mk_lex_combinator_test (p: (char, token) parser) (expected_token: token)
        (label: string) =
    let test_map (errors: string) (case: char list * token list) : string =
        let(cs, tkns) = case in
        let head_token = (List.hd tkns) in
            match (p cs) with
                | Cons((tkn,_),_) ->
                      let _ = print_string (string_of_bool (head_token == expected_token)) in
                      if ((token_eq head_token expected_token) && 
                              (token_eq tkn head_token)) ||
                          ((not (token_eq head_token expected_token)) && 
                                (not (token_eq tkn head_token)))
                      then errors
                      else errors ^ "\nExpected: " ^ (tkn2str(head_token)) ^ 
                          " Lexed: " ^ (tkn2str(tkn))
                | Nil ->
                      if (head_token == expected_token)
                      then errors ^ "\nReturned no token but expected: " ^
                          (tkn2str(head_token))
                      else errors in
    let result = List.fold_left test_map "" lex_test_inputs in
        if (result <> "")
        then Verbose_Test(result, (fun () -> (false, label)))
        else Verbose_Test("", (fun () -> (true, label)))

let test_id_combinator = 
    (mk_lex_combinator_test id_combinator (Id "foo") "Combinator for Id")
let test_int_combinator =
    (mk_lex_combinator_test int_combinator (Int 5) "Combinator for Int");;
let test_plus_combinator =
    (mk_lex_combinator_test plus_combinator (Plus) "Combinator for Plus");;

run_test_set [stub] "Test Stub";;
run_test_set [test_id_combinator; 
              test_int_combinator;
              test_plus_combinator ] "Token Combinator Tests"




   
    
