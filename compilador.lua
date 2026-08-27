--[[
A Lua Compiler That Compile Itself

@Author Daniel Nocito
]]


-- =====
-- TOKEN
-- =====
function Token(tag, value, lin, col)
    return {
        tag   = tag,    -- ex: "NUM", "IDENT", "PLUS", "EOF"
        value = value,  -- Valor Semântico (ex: "123", "x", "+", nil)
        lin   = lin,    -- Linha de início
        col   = col     -- Coluna de início
    }
end

function print_token(t)
    -- Token sem valor semântico
    if value == nil then
        print(string.format(
            "%d\t%d\t%s", 
            t.lin, 
            t.col,
            t.tag
        ))

    -- Token com valor semântico
    else
        print(string.format(
            "%d\t%d\t%s\n%s",
            t.lin, 
            t.col,
            t.tag,
            tostring(t.value)
        ))
    end
end

-- =====
-- LEXER
-- =====

-- Inicializa variáveis globais
function lexer_init()
    -- DEFINIÇÃO DAS TAGS
    Tag = {
        EOF    = "EOF",     -- Fim de arquivo
        NUMBER = "NUMBER",  -- Inteiros decimais ou hexadecimais (ex: 42, 0xFF)
        STRING = "STRING",  -- Literais de string com escapes interpretados
        NAME   = "NAME",    -- Identificadores / nomes de variáveis

        -- Palavras Reservadas
        ["and"]      = "and",
        ["break"]    = "break",
        ["do"]       = "do",
        ["else"]     = "else",
        ["elseif"]   = "elseif",
        ["end"]      = "end",
        ["false"]    = "false",
        ["for"]      = "for",
        ["function"] = "function",
        ["if"]       = "if",
        ["in"]       = "in",
        ["local"]    = "local",
        ["nil"]      = "nil",
        ["not"]      = "not",
        ["or"]       = "or",
        ["repeat"]   = "repeat",
        ["return"]   = "return",
        ["then"]     = "then",
        ["true"]     = "true",
        ["until"]    = "until",
        ["while"]    = "while",

        -- Operadores
        ["+"]   = "+",
        ["-"]   = "-",
        ["*"]   = "*",
        ["/"]   = "/",
        ["%"]   = "%",
        ["^"]   = "^",
        ["#"]   = "#",
        ["=="]  = "==",
        ["~="]  = "~=",
        ["<="]  = "<=",
        [">="]  = ">=",
        ["<"]   = "<",
        [">"]   = ">",
        ["="]   = "=",
        ["("]   = "(",
        [")"]   = ")",
        ["{"]   = "{",
        ["}"]   = "}",
        ["["]   = "[",
        ["]"]   = "]",
        [";"]   = ";",
        [":"]   = ":",
        [","]   = ",",
        ["."]   = "."
        [".."]  = "..",
        ["..."] = "..."
    }

    -- String interia do arquivo
    buffer = io.read("*a") or ""

    pos = 1 -- Posição do próx char não lido
    lin = 1 -- Posição da linha
    col = 1 -- Posição da coluna

    c = ""
end


function lexer_avanca()
    -- Lê o primeiro char não lido
    c = buffer:sub(pos, pos)
    if c == "" then
        c = nil -- EOF
    end

    -- Atualiza a posição do próx char não lido
    pos = pos + 1
end


-- Consome chars até ler um token inteiro (mais longo possível)
-- e retorna este token (ou o especial EOF)
function lexer_get_token()
    if c == nil then
        return Token("EOF")
    
    elseif c == "+" then
        lexer_avanca()
        return Token("+")
end