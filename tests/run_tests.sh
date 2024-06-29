#!/bin/bash

# Caminhos executando dentro de tests
# EXEC=../parser
# TEST_CASES_DIR=./test_cases

# caminhos executando da raiz
EXEC=./parser
TEST_CASES_DIR=./tests

# Contadores de sucesso e falha
SUCCESS=0
FAIL=0

# Função para rodar um caso de teste
run_test() {
  local input_file=$1
  local expected_output_file=$2
  local test_name=$(basename ${input_file} _input.txt)

  # Redireciona a entrada e captura a saída
  output=$(cat ${input_file} | ${EXEC})

  # Lê a saída esperada
  expected_output=$(cat ${expected_output_file})

  # Compara a saída com a saída esperada
  if [ "${output}" == "${expected_output}" ]; then
    echo "Teste ${test_name} passou."
    SUCCESS=$((SUCCESS+1))
  else
    echo "Teste ${test_name} falhou."
    echo "Esperado:"
    echo "${expected_output}"
    echo "Obtido:"
    echo "${output}"
    FAIL=$((FAIL+1))
  fi
}

# Loop pelos casos de teste
for input_file in ${TEST_CASES_DIR}/*_input.txt; do
  expected_output_file=${input_file/_input.txt/_expected_output.txt}
  if [ -f ${expected_output_file} ]; then
    run_test ${input_file} ${expected_output_file}
  else
    echo "Arquivo de saída esperada correspondente não encontrado para ${input_file}"
    FAIL=$((FAIL+1))
  fi
done

# Resultados finais
echo
echo "Total de testes: $((SUCCESS+FAIL))"
echo "Passaram: ${SUCCESS}"
echo "Falharam: ${FAIL}"

# Retorna 0 se todos os testes passaram, 1 caso contrário
if [ ${FAIL} -eq 0 ]; then
  exit 0
else
  exit 1
fi

