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
        ["."]   = ".",
        [".."]  = "..",
        ["..."] = "..."
    }

    -- Tabela de "abre" e "fecha"
    Pares = {
        ["("] = ")",
        ["["] = "]",
        ["{"] = "}",
        ['"'] = '"',
        ["'"] = "'",
        ["="] = "=",
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
end


function lexer_teste_eh_sep(c)
    return (
        c == " " or 
        -- c == ";" or 
        c == "\t" or
        c == "\f" or
        c == "\v"
    )
end


function lexer_teste_eh_letra(c)
    local byte = string.byte(c)
    
    -- Tabela ASCII: 
    -- 'A' a 'Z' = 65 a 90
    -- 'a' a 'z' = 97 a 122
    return (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122)
end


function lexer_teste_eh_numero(c)
    local byte = string.byte(c)
    
    -- Tabela ASCII:
    -- '0' a '9' = 48 a 57
    return byte >= 48 and byte <= 57
end


function lexer_teste_eh_palavra_reservada(p)
    -- Verifica se é Tag conhecida (não necessariamente reservada)
    if Tag[p] ~= nil then
        -- Ignora tags de categorias (são strings válidas)
        return not (
            p == "EOF" or 
            p == "NUMBER" or
            p == "STRING" or
            p == "NAME" or
            p == "FLOAT"
        )
        end
    end
    return false
end


function lexer_teste_eh_escape_string(c)
    return (
        c == "\a" or
        c == "\b" or
        c == "\f" or
        c == "\v" or
        c == "\32" or
        c == "\x0A" or
        c == "\u{230}" or
        c == "\z"
    )
end


-- Imprime uma mensagem de erro pouco explicativa
function lexer_erro()
    print(string.format(
        "%d\t%d",
        lin,
        col
    ))

    os.exit(1)
end


function lexer_parse_string()
    local token_lin = lin
    local token_col = col
    local conteudo = ""
    local delimitador = c

    -- STRINGS CURTAS ("..." ou '...')
    if delimitador == '"' or delimitador == "'" then
        lexer_avanca() -- consome a aspa de abertura

        while c ~= nil and c ~= delimitador do
            if lexer_teste_eh_newline(c) then
                lexer_erro() -- quebra de linha literal não é permitida
            elseif c == "\\" then
                -- preserva o caractere de escape e o caractere seguinte
                conteudo = conteudo .. c
                lexer_avanca()
                if c == nil then lexer_erro() end
                conteudo = conteudo .. c
            else
                conteudo = conteudo .. c
            end
            lexer_avanca()
        end

        if c == nil then lexer_erro() end -- fim de arquivo sem fechar aspas
        lexer_avanca() -- consome a aspas de fechamento

        return Token(Tag["STRING"], conteudo, token_lin, token_col)

    -- STRINGS LONGAS ([[...]], [=[...]=], etc)
    elseif delimitador == "[" then
        local num_iguais = 0
        
        lexer_avanca() -- Consome o primeiro '['
        
        while c == "=" do
            num_iguais = num_iguais + 1
            lexer_avanca()
        end
        
        if c ~= "[" then
            -- formato inválido (não formou um [[ ou [=[)
            lexer_erro()
        end
        
        lexer_avanca() -- Consome o segundo '['

        -- itera o conteúdo
        local fechou = false
        while c ~= nil or not fechou do
            if c == "]" then
                -- verifica se fechou corretamente
                local offset = 0
                while lexer__get_char(offset) == "=" do
                    offset = offset + 1
                end
                
                if lexer__get_char(offset) == "]" and offset == num_iguais then
                    -- match exato de fechamento
                    fechou = true
                    
                    -- itera para consumir a tag de fechamento
                    lexer_avanca() -- consome o ']'
                    
                    local i = 1
                    while i <= num_iguais do
                        lexer_avanca()
                        i = i + 1
                    end
                end
            end
            
            conteudo = conteudo .. c
            lexer_avanca()
        end

        if not fechou then lexer_erro() end

        return Token(Tag["STRING"], conteudo, token_lin, token_col)
    end

    lexer_erro()
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
        if lexer__get_char(0) == "[" or lexer__get_char(0) == "=" then
            return lexer_parse_string()
        else
            lexer_avanca()
            return Token(Tag["["], nil, lin, col)
        end
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
    elseif c == "\"" or c == "'" then
        return lexer_parse_string()

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
    
    -- Tratamento de Textos
    elseif lexer_teste_eh_letra(c) or c == "_" then
        -- anotamos a pos de início do identificador
        local pos_inicio = pos

        -- consumimos o restante do identificador
        while lexer_teste_eh_letra(c) or c == "_" or  lexer_teste_eh_numero(c) do
            lexer_avanca()
        end
        local identificador = buffer:sub(pos_inicio, pos - 1)

        if lexer_teste_eh_palavra_reservada(identificador) then
            return Token(Tag[identificador], nil, lin, col)
        else
            return Token(Tag["NAME"], identificador, lin, col)
        end
    
    elseif c == "\"" then
        return lexer_parse_string()


    elseif lexer_teste_eh_sep(c) then
        while lexer_teste_eh_sep(c) do
            lexer_avanca()
        end

        return lexer_get_token()
    
    else
        return lexer_erro()
    end
end