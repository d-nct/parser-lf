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
        ["EOF"]    = "EOF",
        ["NUMBER"] = "NUMBER",
        ["STRING"] = "STRING",
        ["NAME"]   = "NAME",
        ["FLOAT"]  = "FLOAT",

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
        ["+"]   = "+", -- ok
        ["-"]   = "-", -- ok
        ["*"]   = "*", -- ok
        ["/"]   = "/", -- ok
        ["%"]   = "%", -- ok
        ["^"]   = "^", -- ok
        ["#"]   = "#", -- ok
        ["=="]  = "==", -- ok
        ["~="]  = "~=", -- ok
        ["<="]  = "<=", -- ok
        [">="]  = ">=", -- ok
        ["<"]   = "<", -- ok
        [">"]   = ">", -- ok
        ["="]   = "=", -- ok
        ["("]   = "(", -- ok
        [")"]   = ")", -- ok
        ["{"]   = "{", -- ok
        ["}"]   = "}", -- ok
        ["["]   = "[", -- ok
        ["]"]   = "]", -- ok
        [";"]   = ";", -- ok
        [":"]   = ":", -- ok
        [","]   = ",", -- ok
        ["."]   = "." -- ok
        [".."]  = "..", -- ok
        ["..."] = "..." -- ok
    }

    -- String interia do arquivo
    buffer = io.read("*a") or ""

    pos = 1 -- Posição do próx char não lido
    lin = 1 -- Posição da linha
    col = 1 -- Posição da coluna

    c = ""
end


-- Retorna o n-ésimo caractere não lido
function lexer__get_char(offset)
    local p = pos + offset
    if p > #buffer then
        return nil
    end
    return buffer:sub(p,p)

function lexer_avanca()
    -- Atualiza lin, col
    if lexer_teste_eh_newline(c) then
        col = col + 1
        lin = 1
    else
        lin = lin + 1
    end

    -- Lê os chars a frente
    c  = lexer__get_char(pos)   -- Primeiro char não lido
    c2 = lexer__get_char(pos+1) -- Segundo char não lido
    c3 = lexer__get_char(pos+2) -- Terceiro char não lido

    -- Atualiza a posição do próx char não lido
    pos = pos + 1
end


function lexer_teste_eh_newline(c)
    return (
        c == "\n" or
        c == "\r"
    )


function lexer_teste_eh_sep(c)
    return (
        c == " " or 
        -- c == ";" or 
        c == "\t" or
        c == "\f" or
        c == "\v"
    )
end


-- Imprime uma mensagem de erro pouco explicativa
function lexer_erro()
    print(string.format(
        "%d\t%d",
        lin,
        col
    ))
end


-- Consome chars até ler um token inteiro (mais longo possível)
-- e retorna este token (ou o especial EOF)
function lexer_get_token()
    -- EOF
    if c == nil then
        return Token(Tag["EOF"], nil, lin, col)
    
    -- Operadores Sem Dúvida
    elseif c == "+" then
        lexer_avanca()
        return Token(Tag["+"], nil, lin, col)
    elseif c == "-" then
        lexer_avanca()
        return Token(Tag["-"], nil, lin, col)
    elseif c == "*" then
        lexer_avanca()
        return Token(Tag["*"], nil, lin, col)
    elseif c == "/" then
        lexer_avanca()
        return Token(Tag["/"], nil, lin, col)
    elseif c == "%" then
        lexer_avanca()
        return Token(Tag["%"], nil, lin, col)
    elseif c == "^" then
        lexer_avanca()
        return Token(Tag["^"], nil, lin, col)
    elseif c == "#" then
        lexer_avanca()
        return Token(Tag["#"], nil, lin, col)
    elseif c == "(" then
        lexer_avanca()
        return Token(Tag["("], nil, lin, col)
    elseif c == ")" then
        lexer_avanca()
        return Token(Tag[")"], nil, lin, col)
    elseif c == "{" then
        lexer_avanca()
        return Token(Tag["{"], nil, lin, col)
    elseif c == "}" then
        lexer_avanca()
        return Token(Tag["}"], nil, lin, col)
    elseif c == "[" then
        lexer_avanca()
        return Token(Tag["["], nil, lin, col)
    elseif c == "]" then
        lexer_avanca()
        return Token(Tag["]"], nil, lin, col)
    elseif c == ";" then
        lexer_avanca()
        return Token(Tag[";"], nil, lin, col)
    elseif c == ":" then
        lexer_avanca()
        return Token(Tag[":"], nil, lin, col)
    elseif c == "," then
        lexer_avanca()
        return Token(Tag[","], nil, lin, col)

    elseif c == "~" then
        lexer_avanca()
        if c == "=" then
            lexer_avanca()
            return Token(Tag["~="], nil, lin, col)
        else
            return lexer_erro()
    
    -- Operadores Que Dependem de c+1
    elseif c == "=" then
        lexer_avanca()
        if c == "=" then
            lexer_avanca()
            return Token(Tag["=="], nil, lin, col)
        elseif lexer_teste_eh_sep(c) then
            return Token(Tag["="], nil, lin, col)
        else
            return lexer_erro()
        end

    elseif c == "<" then
        lexer_avanca()
        if c == "=" then
            lexer_avanca()
            return Token(Tag["<="], nil, lin, col)
        elseif lexer_teste_eh_sep(c) then
            lexer_avanca()
            return Token(Tag["<"], nil, lin, col)
        else
            return lexer_erro()
        end

    elseif c == ">" then
        lexer_avanca()
        if c == "=" then
            lexer_avanca()
            return Token(Tag[">="], nil, lin, col)
        elseif lexer_teste_eh_sep(c) then
            lexer_avanca()
            return Token(Tag[">"], nil, lin, col)
        else
            return lexer_erro()
        end

    elseif c == "." then
        lexer_avanca()
        if c == "." then
            lexer_avanca()
            if c == "." then
                lexer_avanca()
                return Token(Tag["..."], nil, lin, col)
            else 
                return lexer_erro()
            end
            return Token(Tag[".."], nil, lin, col)
        elseif lexer_teste_eh_sep(c) then
            lexer_avanca()
            return Token(Tag["."], nil, lin, col)
        else
            return lexer_erro()
        end
    
    


end