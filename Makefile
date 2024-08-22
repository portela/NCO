#
# https://www.linkedin.com/in/henriqueportela/
#
# Makefile Commands
#
# $ make compile
#	- Cria o diretório WORKDIR se ele não existir.
#	- Acha todos os arquivos vhdl dentro de src/ (ALL_FILES).
#	- Acha todas simulações dentro de src/ (TESTBENCH_SIMULATION_FILES).
#	- Para todos os arquivos encontrados, executa analise de ghdl (GHDL_ANALIZE).
#	- Para todas as simulações, executa ghdl (GHDL_RUN) e gera os arquivos .vcd no WORKDIR.
#
# $ make <filename>
#	- Cria o diretório WORKDIR se ele não existir.
#   - Acha todos os arquivos vhdl dentro de src/ iniciados por <filename>.
#	- Acha todas simulações dentro de src/ iniciadas por <filename>
#	- Para todos os arquivos encontratos, executa analise de ghdl (GHDL_ANALIZE).
#	- Para todas as simulações econtradas, executa ghdl (GHDL_RUN) e gera os arquivos .vcd no WORKDIR.
#
# $ make view
#	- Exibe uma lista de todos os arquivos de simulação disponíveis no WORKDIR.
#
# $ make view <filename>
#	- Procura o caminho completo para o arquivo dentro de WORKDIR, que pode ter extensão .gtkw, .vcd ou .ghw (nessa ordem).
#	- Se encontrar o caminho, abre o arquivo correspondente no GTKWave com o comando $(GTKWAVE_CMD) <filename_with_extension_and_path>.
#	- Se não encontrar, exibe uma mensagem de erro.
#
# $ make clean
# 	- Apaga todos os arquivos .cf, .vcd e .ghw do WORKDIR.
#	- Não apaga demais arquivos, como .gtwk (arquivo com configuração de view do GTKWave).
#	- Se WORKDIR estiver vazio, apaga ele.
#


GHDL_CMD  	   := ghdl
GHDL_FLAGS 	   := --ieee=synopsys -fexplicit
GHDL_IMPORT    := $(GHDL_CMD) -i $(GHDL_FLAGS)
GHDL_ANALIZE   := $(GHDL_CMD) -a $(GHDL_FLAGS)
GHDL_ELABORATE := $(GHDL_CMD) -e $(GHDL_FLAGS)
GHDL_MAKE      := $(GHDL_CMD) -m $(GHDL_FLAGS)
GHDL_RUN       := $(GHDL_CMD) -r $(GHDL_FLAGS)

GTKWAVE_CMD	   := gtkwave

STOP_TIME 		:= 100us
GHDL_SIM_OPT 	:= --stop-time=$(STOP_TIME)
#GHDL_SIM_OPT 	:= --assert-level=error

WORKDIR  := work

# _FILES: full path  
# _NAMES: only file name
ALL_FILES 	   			   := $(shell find ./src -type f -name "*.vhd")
TESTBENCH_SIMULATION_FILES := $(shell find $(WORKDIR) -type f \( -name "*.vcd" -o -name "*.ghw" \))
TESTBENCH_SOURCE_NAMES 	   := $(shell find ./src -type f -name "*_tb*.vhd" -exec basename {} .vhd \;)
TESTBENCH_SIMULATION_NAMES := $(shell find $(WORKDIR) -type f \( -name "*.vcd" -o -name "*.ghw" \) | xargs -n 1 basename | sed -e 's/\.[^./]*$$//' | sort -V)



# Echo Color Table
# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
NOCOLOR='\033[0m'
COLOR1='\033[0;35m'
COLOR2='\033[0;32m'


hello:
	@echo "World!"


compile:
	$(shell mkdir -p $(WORKDIR))
	@echo $(ALL_FILES)
	@$(GHDL_ANALIZE) --workdir=$(WORKDIR) $(ALL_FILES)
	@echo $(COLOR1) "\t Generating tests: " $(NOCOLOR)
	@for file in $(TESTBENCH_SOURCE_NAMES); do \
		echo $(COLOR2)  "\t\t $$file" $(NOCOLOR); \
    done
	@for file in $(TESTBENCH_SOURCE_NAMES); do \
        $(GHDL_RUN) --workdir=$(WORKDIR) $$file --wave=$$file.ghw $(GHDL_SIM_OPT); \
		mv $$file.ghw $(WORKDIR); \
    done


view:
ifeq ($(word 2, $(MAKECMDGOALS)),)
	@echo "\tChoose simulation to run:"
	@for name in $(TESTBENCH_SIMULATION_NAMES); do \
		echo "\t\t$$name"; \
	done
else
	@prefix=$(word 2, $(MAKECMDGOALS)); \
	matched_name=$$(for name in $(TESTBENCH_SIMULATION_NAMES); do \
		echo $$name | grep -E "^$$prefix" && break; \
	done); \
	if [ -z "$$matched_name" ]; then \
		echo "Error: No matching simulation found for prefix '$$prefix'"; \
		exit 1; \
	else \
		file_path=$$(find $(WORKDIR) -type f \( -name "$$matched_name.gtkw" -o -name "$$matched_name.vcd" -o -name "$$matched_name.ghw" \) | head -n 1); \
		if [ -n "$$file_path" ]; then \
			echo "Opening $$file_path with $(GTKWAVE_CMD)"; \
			$(GTKWAVE_CMD) $$file_path; \
		else \
			echo "Error: File $$matched_name not found with .gtkw, .vcd, or .ghw extension"; \
			exit 1; \
		fi; \
	fi
endif


clean:
	@echo $(COLOR1) "\t Removing *.cf, *.vcd amd *.ghw from \$$WORKDIR" $(NOCOLOR)
	@echo $(COLOR1) "\t Deleting \$$WORKDIR if empty" $(NOCOLOR)
	@find $(WORKDIR) -type f \( -name "*.cf" -o -name "*.vcd" -o -name "*.ghw" \) -exec rm -f {} +
	@find $(WORKDIR) -type d -empty -exec rmdir {} +



%:
	@echo $(COLOR1) "\tProcessing $@ ..." $(NOCOLOR)
	$(shell mkdir -p $(WORKDIR))

# Acha todos os arquivos VHDL dentro de src/ iniciados por <filename>.
	@vhdl_files=$$(find ./src -type f -name "$@*.vhd"); \
	if [ -z "$$vhdl_files" ]; then \
		echo "Error: No VHDL files found starting with '$@'"; \
		exit 1; \
	fi; \
	echo $(COLOR2) "\t\tFound VHDL files:" $$vhdl_files $(NOCOLOR); \
	for file in $$vhdl_files; do \
		$(GHDL_ANALIZE) --workdir=$(WORKDIR) $$file; \
	done

# Acha todas simulações dentro de src/ iniciadas por <filename>
	@testbenches=$$(find ./src -type f -name "$@*_tb*.vhd"); \
	if [ -z "$$testbenches" ]; then \
		echo "Error: No testbenches found starting with '$@'"; \
		exit 1; \
	fi; \
	echo $(COLOR2) "\t\tFound testbenches:" $$testbenches $(NOCOLOR); \
	for tb in $$testbenches; do \
		tb_name=$$(basename $$tb .vhd); \
		$(GHDL_RUN) --workdir=$(WORKDIR) $$tb_name --wave=$$tb_name.ghw $(GHDL_SIM_OPT); \
		mv $$tb_name.ghw $(WORKDIR); \
	done
