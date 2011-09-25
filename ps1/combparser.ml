(* This file should be extended to implement the Fish parser using the 
 * parsing combinator library, and the combinator-based lexer. *)
open Lcombinators.GenericParsing
open Comblexer
open Ast

exception TODO
exception InvalidSyntax
    
(* Helpful parsers *)
let token_equal(target_token: rtoken) : (token, token) parser =
    (satisfy (fun t_token -> 
                let subrtoken = get_token_rtoken t_token in 
                subrtoken = target_token ))

(* Function packaging If Statement           *)         
let pkg_if (target : (token * (exp * (stmt * (token * stmt) option)))) : stmt = 
    let position = get_token_position (fst target) in
    match target with 
    | (_, (t_expr, (s_then, Some(_, s_else)))) -> (If(t_expr, s_then, s_else), position)
    | (_, (t_expr, (s_then, None)))            -> (If(t_expr, s_then, (skip, position)),   position)

(* Function packaging Return Statement       *)                                                                                          
let pkg_return (target : (token * exp)) : stmt =
    let position = get_token_position (fst target) in
    match target with 
    | (_, t_expr) -> (Return(t_expr), position)
    
(* Function packaging While Statement        *)
let pkg_while (target : (token * (exp * stmt))) : stmt = 
    let position = get_token_position (fst target) in                      
    match target with 
    | (_, (t_expr, t_stmt)) -> (While(t_expr, t_stmt), position)

(* Function packaging Blocks of Statement    *)
let pkg_seq (target : (token * (stmt list * token))) : stmt =
    match target with 
    | (_, (stmts, _)) -> (List.fold_left 
                               (fun (sequence : stmt) (elt : stmt) ->
                                    let position = get_stmt_position elt in                      
                                    (Seq(elt, sequence)), position)
                               (skip, get_token_position (fst target))
                               stmts)

(* Function to package a paren'd parse_expression   *) 
let pkg_paren_expr (target : (token * (exp * token))) : exp = 
    match target with 
    | (_, (t_exp, _)) -> t_exp

(* Function to package a Not expression *)
let pkg_not_init (target : (token * exp)) : exp = 
    let position = get_token_position (fst target) in                      
    match target with 
    | (_, t_exp) -> (Not(t_exp), position)
    
(* Function to package Int-init parse_expression    *) 
let pkg_int_init (target : (token option * (token * (token * exp) option))) : exp = 
    let sign = 
            match (fst target) with 
            | Some(_) -> -1
            | None    -> 1
    in 
    match (snd target) with
    | ((Comblexer.Int(num), position), Some((Comblexer.Plus,  _), t_expr)) -> (Binop((Int(sign * num), position), Plus,  t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.Minus, _), t_expr)) -> (Binop((Int(sign * num), position), Minus, t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.Times, _), t_expr)) -> (Binop((Int(sign * num), position), Times, t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.Div,   _), t_expr)) -> (Binop((Int(sign * num), position), Div,   t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.Gt,    _), t_expr)) -> (Binop((Int(sign * num), position), Gt,    t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.Gte,   _), t_expr)) -> (Binop((Int(sign * num), position), Gte,   t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.Lte,   _), t_expr)) -> (Binop((Int(sign * num), position), Lte,   t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.Lt,    _), t_expr)) -> (Binop((Int(sign * num), position), Lt,    t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.Eq,    _), t_expr)) -> (Binop((Int(sign * num), position), Eq,    t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.Neq,   _), t_expr)) -> (Binop((Int(sign * num), position), Neq,   t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.Or,    _), t_expr)) -> (Or(   (Int(sign * num), position), t_expr), position)
    | ((Comblexer.Int(num), position), Some((Comblexer.And,   _), t_expr)) -> (And(  (Int(sign * num), position), t_expr), position)
    | ((Comblexer.Int(num), position), None)                               -> (Int(sign * num), position)
    | _                                                                    -> raise InvalidSyntax
    
(* Function to package Int-init parse_expression    *) 
let pkg_var_init (target : (token * (token * exp) option)) : exp = 
    let position = get_token_position (fst target) in
    match target with
    | ((Comblexer.Var(name), _), Some((Comblexer.Plus,   _), t_expr)) -> (Binop( (Var(name), position), Plus,  t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Minus,  _), t_expr)) -> (Binop( (Var(name), position), Minus, t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Times,  _), t_expr)) -> (Binop( (Var(name), position), Times, t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Div,    _), t_expr)) -> (Binop( (Var(name), position), Div,   t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Gt,     _), t_expr)) -> (Binop( (Var(name), position), Gt,    t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Gte,    _), t_expr)) -> (Binop( (Var(name), position), Gte,   t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Lte,    _), t_expr)) -> (Binop( (Var(name), position), Lte,   t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Lt,     _), t_expr)) -> (Binop( (Var(name), position), Lt,    t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Eq,     _), t_expr)) -> (Binop( (Var(name), position), Eq,    t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Neq,    _), t_expr)) -> (Binop( (Var(name), position), Neq,   t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Or,     _), t_expr)) -> (Or(    (Var(name), position),        t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.And,    _), t_expr)) -> (And(   (Var(name), position),        t_expr), position)
    | ((Comblexer.Var(name), _), Some((Comblexer.Assign, _), t_expr)) -> (Assign(name, t_expr), position)
    | ((Comblexer.Var(name), _), None)                                -> (Var(name), position)
    | _                                                               -> raise InvalidSyntax


(* Function packaging For Statement          *)        
let pkg_for (target : (token * (token * 
                        (exp * (token * (exp * (token * (exp * 
                        (token * stmt) ))))))))
            : stmt = 
    let position = get_token_position (fst target) in 
    match target with 
    | (_, (_, (i_expr, (_, (c_expr, (_, (n_expr, (_, t_stmt)))))))) ->
            (For(i_expr, c_expr, n_expr, t_stmt), position)    

(* Function packaging expressions -> stmt     *)
let pkg_s_expression (target : exp) : stmt = 
    (Exp(target), get_exp_position target)

(* Parser matching Expressions                *)
let rec parse_expression : (token, exp) parser = 
    (alts [ parse_int_init; 
            parse_var_init; 
            parse_paren_expr;
            parse_not_init ])

(* Expression Parsers *) 

(* Parameterized Parser for      [binop] expr *) 
and parse_half_binop(operation : rtoken) : (token, (token * exp)) parser = 
    (seq 
        ((token_equal operation),
        parse_expression))

(* Parser for an Int-initiated parse_expression     *)
and parse_int_init : (token, exp) parser = 
    (map pkg_int_init
        (seq 
            ((opt (token_equal Comblexer.Minus)),
            (seq
                ((satisfy 
                    (fun t_token ->
                        let subrtoken = get_token_rtoken t_token in
                        match subrtoken with 
                        | Comblexer.Int(_) -> true
                        | _                -> false 
                    )),
                (opt
                    (alts 
                     [ (parse_half_binop Comblexer.Plus);
                       (parse_half_binop Comblexer.Times);
                       (parse_half_binop Comblexer.Div);
                       (parse_half_binop Comblexer.Minus);
                       (parse_half_binop Comblexer.Lte);
                       (parse_half_binop Comblexer.Lt);
                       (parse_half_binop Comblexer.Eq);
                       (parse_half_binop Comblexer.Neq);
                       (parse_half_binop Comblexer.Gt);
                       (parse_half_binop Comblexer.Gte);
                       (parse_half_binop Comblexer.Or);
                       (parse_half_binop Comblexer.And)
                     ] )
                ) )))))

(* Parser for a Var-initiated parse_expression      *)
and parse_var_init : (token, exp) parser =
    (map pkg_var_init
         (seq
            ((satisfy 
                (fun t_token ->
                    let subrtoken = get_token_rtoken t_token in
                    match subrtoken with
                    | Comblexer.Var(_) -> true
                    | _                -> false 
                )),
             (opt 
                 (alts 
                  [    (parse_half_binop Comblexer.Plus);
                       (parse_half_binop Comblexer.Times);
                       (parse_half_binop Comblexer.Div);
                       (parse_half_binop Comblexer.Minus);
                       (parse_half_binop Comblexer.Lte);
                       (parse_half_binop Comblexer.Lt);
                       (parse_half_binop Comblexer.Eq);
                       (parse_half_binop Comblexer.Neq);
                       (parse_half_binop Comblexer.Gt);
                       (parse_half_binop Comblexer.Gte);
                       (parse_half_binop Comblexer.Or);
                       (parse_half_binop Comblexer.And);
                       (parse_half_binop Comblexer.Assign)
                  ] )
             ))))

(* Parser for Paren-contained parse_expression      *)
and parse_paren_expr : (token, exp) parser = 
    (map pkg_paren_expr 
         (seq 
             ((token_equal Comblexer.LParen),
             (seq
                 (parse_expression,
                 (token_equal Comblexer.RParen))
             ))))

(* Parser for Paren-contained parse_expression      *)
and parse_not_init : (token, exp) parser = 
    (map pkg_not_init 
        (seq 
            ((token_equal Comblexer.Not),
            parse_expression)))

(* Statement Parsers *)
let rec parse_statement : (token, stmt) parser =
    (alts [ parse_if;
            parse_for;
            parse_while;
            parse_return;
            parse_seq;
            parse_s_expression
          ] )

(* Parser matching Return Statement          *) 
and parse_return : (token, stmt) parser = 
    (map pkg_return 
       (seq 
           ((token_equal Comblexer.Return ), 
           parse_expression) ))

(* Parser matching If Statement              *)
and parse_if : (token, stmt) parser = 
    (map pkg_if
       (seq 
           ((token_equal Comblexer.If),
           (seq 
               (parse_expression,
               (seq 
                   (parse_statement,
                   (opt 
                       (seq 
                           ((token_equal Comblexer.Else),
                           parse_statement)
                       )))))))))

(* Parser matching While Statement           *) 
and parse_while : (token, stmt) parser = 
    (map pkg_while 
       (seq 
           ((token_equal Comblexer.While), 
           (seq 
               (parse_expression,
               parse_statement))))) 

(* Parser matching For Statement             *)
(* TODO implement mapping to get correct types *)
and parse_for : (token, stmt) parser = 
    (map pkg_for
       (seq
           ((token_equal Comblexer.For),
           (seq 
               ((token_equal Comblexer.LParen),
               (seq
                   (parse_expression,
                   (seq 
                       ((token_equal Comblexer.Seq), 
                       (seq 
                           (parse_expression, 
                           (seq
                               ((token_equal Comblexer.Seq),
                               (seq
                                   (parse_expression,
                                   (seq
                                       ((token_equal Comblexer.RParen),
                                       parse_statement)
                                   ))))))))))))))))

(* Parser matching Blocks of Statement { x } *) 
and parse_seq : (token, stmt) parser = 
    (map pkg_seq
       (seq 
           ((token_equal Comblexer.LCurly),
           (seq 
               ((star parse_statement),
               token_equal Comblexer.RCurly) 
           ))))

(* Parser pushing an isolated expr -> stmt    *)
and parse_s_expression : (token, stmt) parser =
    (map pkg_s_expression 
       parse_expression)

let rec parse(ts:token list) : program = 
    raise ImplementMe


