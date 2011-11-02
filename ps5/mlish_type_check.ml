open Mlish_ast
open Environment 

exception TypeError

let type_error(s:string) = (print_string s; raise TypeError)

(* Guess Manipulators *)

(* Unifies types *)
let rec unify a_type b_type = 
  (* Compare for easy equality *)
  if a_type = b_type then true
  else match (a_type, b_type) with 
  | (Guess(t_guess as (ref None)), b_type)  -> 
      (* If a_ is not yet assigned, assign it  *)
      let _ = t_guess := Some b_type in true
 
  | (Guess(ref Some(t_guess)), b_type)      -> 
      (* If a_ is a guess, try to resolve it   *)
      unify t_guess b_type

  (* If b_ is a guess, use a_ to assign it *)
  | (a_type, Guess(_))        -> unify b_type a_type

  (* Recurse if functions involved *)
  | (Fn_t(l_atype, r_atype), Fn_t(l_btype, r_btype)) ->  
    (unify l_atype r_atype) && (unify l_btype r_btype)

(* Creates a new Guess *)
let guess () = 
  Guess_t(ref None)

(* Follows guess links until an end is found *)
let rec resolve t_type = 
  match t_type with
  | Guess_t(ref None)         -> None
  | Guess_t(ref Some(n_type)) -> resolve n_type
  | _                         -> t_type

(* Attempts to resolve a type, setting it if it isnt assigned *)
let rec resolve_or_set t_type set_type = 
  match t_type with
  | (Guess(t_guess as (ref None)), b_type)  -> 
      (* If a_ is not yet assigned, assign it  *)
      let _ = t_guess := set_type in set_type

  | (Guess(ref Some(t_guess)), b_type)      -> 
      (* If a_ is a guess, try to resolve it   *)
      resolve_or_set t_guess set_type

  | _                                       -> t_type

(* Type Checks *)

let rec check_exp e env = 
  (* Extract rexp *)
  let (t_rexp, _) = e in
  (* Segregate expressions *)
  match t_rexp with
  | Var(v)                 -> check_var v env
  | PrimApp(p, exps)       -> check_prim p exps env
  | Fn(v, t_exp)           -> check_fn v t_exp env
  | App(t_exp, o_exp)      -> check_app t_exp o_exp env
  | If(cond, t_exp, e_exp) -> check_if cond t_exp e_exp env
  | Let(v, t_exp, in_exp)  -> check_let v t_exp in_exp env

and check_var v env =
  (* Look up var *)
  lookup v env

and check_prim p exps env = 
  (* Match primitive possibilities *)
  (* Raw *)

  (* Int ops *)

  (* Pairs *)

  (* Lists *)

and check_fn v t_exp env = 
  (* Add v to the env as a guess *)
  let arg_type = (guess ()) in
  let new_env = push v arg_type env in
  (* Check body *)
  let body_type = check_exp t_exp in
  (* Return function type *)
  Fn_t(arg_type, body_type) 

and check_app t_exp o_exp env = 
  (* Return type is a guess *)
  let return_type = guess () in
  (* Type check both expressions *)
  let (t_type, o_type) = ((check_exp t_exp env), (check_exp o_exp env)) in
  (* Unify first expression as a function that can take the second *)
  if unify t_type (Fn_t(o_type, return_type)) then return_type 
  else raise TypeError

and check_if cond t_exp e_exp env = 
  (* Check condition for bool *)
  let cond_check = check_exp cond env in
  let resolved_type = resolve_or_set cond_check Bool_t in
  if not (resolved_type = Bool_t) then raise TypeError
  else 
    let t_check = check_exp t_exp in
    let e_check = check_exp e_exp in
    (* Check t_exp and e_exp for equality, type *)
    if unify t_check e_check then t_check
    else raise TypeError 

and check_let v t_exp in_exp env =
  (* Create a guess for v in env *)
  (* Check t_exp *)
    (* Assign type to the guess *)
  (* Check in_exp with new environemnt *)

(* Entry Point *)

let type_check_exp (e:Mlish_ast.exp) : tipe =


    