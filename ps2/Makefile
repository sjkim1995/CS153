# We are not really tracking dependencies because everything is small
# enough to recompile at will.

# change to a different ocamlc if you prefer (e.g., ocamlopt)
COMPILER=ocamlc
 
all: clean compile test run_tests

test: compile
	./tests

compile_tests: compile
	./compile_canned.sh

run_tests: compile_tests
	./run_tests.sh 

benchmark: compile_tests
	./benchmark.sh

compile:
	$(COMPILER) -c ast.ml
	ocamlyacc -v parse.mly
	$(COMPILER) -c parse.mli
	$(COMPILER) -c parse.ml
	ocamllex lex.mll
	$(COMPILER) -c lex.ml
	$(COMPILER) -c eval.ml
	$(COMPILER) -c word32.ml
	$(COMPILER) -c mips.ml
	$(COMPILER) -c optimize.ml
	$(COMPILER) -c compile.ml
	$(COMPILER) -c fish.ml
	$(COMPILER) -c pretty_print.ml
	$(COMPILER) -c test_framework.ml
	$(COMPILER) -c compile_tests.ml
	$(COMPILER) -o ps2 ast.cmo parse.cmo lex.cmo eval.cmo  word32.cmo mips.cmo optimize.cmo compile.cmo fish.cmo
	$(COMPILER) -o tests ast.cmo parse.cmo lex.cmo eval.cmo  word32.cmo mips.cmo optimize.cmo compile.cmo pretty_print.cmo test_framework.cmo compile_tests.cmo

clean:
	rm -rf *.cmo *.cmi ps2 parse.ml parse.mli lex.ml tests parse.output compiled_tests
