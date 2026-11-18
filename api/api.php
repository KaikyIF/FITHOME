<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

// Configuração de CORS para o Flutter Web.
$origem = $_SERVER['HTTP_ORIGIN'] ?? '';
$origensPermitidas = array_map(
    'trim',
    explode(',', getenv('FITHOME_ORIGENS_WEB') ?: '')
);

header('Vary: Origin');

if ($origem !== '' && in_array($origem, $origensPermitidas, true)) {
    header('Access-Control-Allow-Origin: ' . $origem);
    header('Access-Control-Allow-Methods: POST, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
}

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
    if ($origem !== '' && in_array($origem, $origensPermitidas, true)) {
        http_response_code(204);
    } else {
        http_response_code(403);
    }
    exit;
}

// Objetivos disponíveis no aplicativo.
const OBJETIVOS = [
    'Perder Peso' => 'emagrecimento',
    'Ganhar Massa' => 'hipertrofia',
    'Melhorar Saúde' => 'saude',
    'Ganhar Flexibilidade' => 'flexibilidade',
];

// Níveis de experiência.
const NIVEIS = [
    'Iniciante' => 'iniciante',
    'Intermediário' => 'intermediario',
    'Avançado' => 'avancado',
];

// Condições de saúde disponíveis.
const CONDICOES = [
    'Nenhuma',
    'Problemas cardíacos',
    'Diabetes',
    'Pressão alta',
    'Problemas articulares',
    'Problemas respiratórios',
    'Gravidez',
    'Lesão recente',
];

// Retorna uma resposta JSON.
function responder(int $estado, array $corpo): never
{
    http_response_code($estado);
    echo json_encode(
        $corpo,
        JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR
    );
    exit;
}

// Resposta para campos inválidos.
function responderCampoInvalido(string $mensagem): never
{
    responder(422, ['erro' => $mensagem]);
}

// Validação das medidas.
function validarMedida(
    array $entrada,
    string $chave,
    float $minimo,
    float $maximo,
    string $mensagem
): float {
    $valor = $entrada[$chave] ?? null;

    if (!is_int($valor) && !is_float($valor)) {
        responderCampoInvalido($mensagem);
    }

    if (
        !is_finite((float) $valor) ||
        $valor < $minimo ||
        $valor > $maximo
    ) {
        responderCampoInvalido($mensagem);
    }

    return round($valor, 2);
}

// Conexão com o MySQL pelo Docker.
function conectarBanco(): PDO
{
    $servidor = getenv('DB_HOST') ?: '127.0.0.1';
    $porta = getenv('DB_PORT') ?: '3306';
    $nome = getenv('DB_NAME') ?: 'fithome';
    $usuario = getenv('DB_USER');
    $senhaBanco = getenv('DB_PASSWORD');

    if ($usuario === false || $senhaBanco === false) {
        throw new RuntimeException(
            'Configure DB_USER e DB_PASSWORD no servidor.'
        );
    }

    return new PDO(
        "mysql:host=$servidor;port=$porta;dbname=$nome;charset=utf8mb4",
        $usuario,
        $senhaBanco,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_EMULATE_PREPARES => false,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
}

// Busca os dados do usuário no banco.
function buscarConta(PDO $banco, int $id): array
{
    $consulta = $banco->prepare('
        SELECT
            u.id,
            u.email,
            p.nome_completo,
            p.altura_cm,
            p.peso_atual_kg,
            a.idade_anos,
            a.imc,
            a.objetivo,
            a.nivel_experiencia,
            a.condicoes_saude
        FROM usuarios u
        LEFT JOIN perfis_usuario p
            ON p.usuario_id = u.id
        LEFT JOIN avaliacoes_iniciais a
            ON a.id = (
                SELECT ai.id
                FROM avaliacoes_iniciais ai
                WHERE ai.usuario_id = u.id
                ORDER BY ai.avaliado_em DESC, ai.id DESC
                LIMIT 1
            )
        WHERE u.id = ?
    ');

    $consulta->execute([$id]);
    $linha = $consulta->fetch();

    if (!$linha) {
        responder(404, ['erro' => 'Usuário não encontrado.']);
    }

    $objetivos = OBJETIVOS + [
        'Ganhar Resistência' => 'condicionamento',
        'Outro' => 'outro',
    ];

    return [
        'id' => (int) $linha['id'],
        'nome' => $linha['nome_completo'] ?? '',
        'email' => $linha['email'],
        'idade' => $linha['idade_anos'] === null
            ? null : (int) $linha['idade_anos'],
        'altura' => $linha['altura_cm'] === null
            ? null : (float) $linha['altura_cm'],
        'peso' => $linha['peso_atual_kg'] === null
            ? null : (float) $linha['peso_atual_kg'],
        'imc' => $linha['imc'] === null
            ? null : (float) $linha['imc'],
        'objetivo' => array_search(
            $linha['objetivo'],
            $objetivos,
            true
        ) ?: 'Perder Peso',
        'nivel' => array_search(
            $linha['nivel_experiencia'],
            NIVEIS,
            true
        ) ?: 'Iniciante',
        'condicoes_saude' => $linha['condicoes_saude'] === null
            ? []
            : json_decode(
                $linha['condicoes_saude'],
                true,
                512,
                JSON_THROW_ON_ERROR
            ),
    ];
}

// Cadastro de novos usuários.
function cadastrar(
    PDO $banco,
    array $entrada,
    string $email,
    string $senha
): never {
    $nome = is_string($entrada['nome'] ?? null)
        ? trim($entrada['nome'])
        : '';

    if (!preg_match('/\A.{1,120}\z/u', $nome)) {
        responderCampoInvalido(
            'Informe um nome com até 120 caracteres.'
        );
    }

    if (preg_match_all('/./us', $senha) < 6) {
        responderCampoInvalido(
            'A senha precisa ter pelo menos 6 caracteres.'
        );
    }

    $idade = $entrada['idade'] ?? null;

    if (!is_int($idade) || $idade < 1 || $idade > 120) {
        responderCampoInvalido(
            'Informe uma idade entre 1 e 120 anos.'
        );
    }

    $altura = validarMedida(
        $entrada,
        'altura',
        30,
        300,
        'Informe uma altura entre 30 e 300 cm.'
    );

    $peso = validarMedida(
        $entrada,
        'peso',
        1,
        999.99,
        'Informe um peso entre 1 e 999,99 kg.'
    );

    $objetivo = $entrada['objetivo'] ?? null;
    $nivel = $entrada['nivel'] ?? null;

    if (
        !is_string($objetivo) ||
        !isset(OBJETIVOS[$objetivo]) ||
        !is_string($nivel) ||
        !isset(NIVEIS[$nivel])
    ) {
        responderCampoInvalido(
            'Selecione um objetivo e um nível válidos.'
        );
    }

    $condicoes = $entrada['condicoes_saude'] ?? null;

    if (
        !is_array($condicoes) ||
        !array_is_list($condicoes) ||
        count($condicoes) < 1 ||
        count($condicoes) > count(CONDICOES) ||
        (
            count($condicoes) > 1 &&
            in_array('Nenhuma', $condicoes, true)
        )
    ) {
        responderCampoInvalido(
            'Selecione condições de saúde válidas ou marque Nenhuma.'
        );
    }

    foreach ($condicoes as $condicao) {
        if (!in_array($condicao, CONDICOES, true)) {
            responderCampoInvalido(
                'Selecione uma condição de saúde válida.'
            );
        }
    }

    $condicoesJson = json_encode(
        array_values(array_unique($condicoes)),
        JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR
    );

    // Calcula o IMC.
    $imc = round(
        $peso / (($altura / 100) ** 2),
        2
    );

    // Protege a senha com bcrypt.
    $hash = password_hash($senha, PASSWORD_BCRYPT);

    // Inicia a transação.
    $banco->beginTransaction();

    try {
        // Cadastra a conta.
        $banco->prepare('
            INSERT INTO usuarios
                (email, senha_hash, algoritmo_senha)
            VALUES (?, ?, ?)
        ')->execute([
            $email,
            $hash,
            'bcrypt'
        ]);

        $id = (int) $banco->lastInsertId();

        // Cadastra o perfil.
        $banco->prepare('
            INSERT INTO perfis_usuario
                (usuario_id, nome_completo, altura_cm, peso_atual_kg)
            VALUES (?, ?, ?, ?)
        ')->execute([
            $id,
            $nome,
            $altura,
            $peso
        ]);

        // Salva a avaliação inicial.
        $banco->prepare('
            INSERT INTO avaliacoes_iniciais
                (
                    usuario_id,
                    idade_anos,
                    imc,
                    objetivo,
                    nivel_experiencia,
                    condicoes_saude,
                    peso_inicial_kg
                )
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ')->execute([
            $id,
            $idade,
            $imc,
            OBJETIVOS[$objetivo],
            NIVEIS[$nivel],
            $condicoesJson,
            $peso
        ]);

        $resultado = buscarConta($banco, $id);

        $banco->commit();

    } catch (Throwable $erro) {
        if ($banco->inTransaction()) {
            $banco->rollBack();
        }

        if (
            $erro instanceof PDOException &&
            ($erro->errorInfo[1] ?? null) === 1062
        ) {
            responder(409, [
                'erro' => 'Este e-mail já está cadastrado. Volte ao login para entrar.'
            ]);
        }

        throw $erro;
    }

    responder(201, ['usuario' => $resultado]);
}

// A API aceita apenas POST.
if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    header('Allow: POST');
    responder(405, ['erro' => 'Use POST.']);
}

// Identifica a ação solicitada.
$acao = $_GET['acao'] ?? '';

if (!in_array($acao, ['cadastro', 'login'], true)) {
    responder(404, ['erro' => 'Ação não encontrada.']);
}

try {
    // Recebe os dados JSON do Flutter.
    $corpo = file_get_contents(
        'php://input',
        false,
        null,
        0,
        16385
    );

    if ($corpo === false || strlen($corpo) > 16384) {
        responder(413, [
            'erro' => 'Requisição muito grande.'
        ]);
    }

    try {
        $entrada = json_decode(
            $corpo,
            true,
            16,
            JSON_THROW_ON_ERROR
        );
    } catch (JsonException) {
        responder(400, [
            'erro' => 'Envie um JSON válido.'
        ]);
    }

    if (!is_array($entrada) || array_is_list($entrada)) {
        responder(400, [
            'erro' => 'Envie um objeto JSON.'
        ]);
    }

    // Valida o e-mail.
    $email = is_string($entrada['email'] ?? null)
        ? strtolower(trim($entrada['email']))
        : '';

    $senha = $entrada['senha'] ?? null;

    if (
        strlen($email) > 190 ||
        !filter_var($email, FILTER_VALIDATE_EMAIL)
    ) {
        responderCampoInvalido(
            'Informe um e-mail válido.'
        );
    }

    if (
        !is_string($senha) ||
        $senha === '' ||
        strlen($senha) > 72 ||
        str_contains($senha, "\0")
    ) {
        responderCampoInvalido(
            'Informe uma senha válida de até 72 bytes.'
        );
    }

    // Conecta ao MySQL.
    $banco = conectarBanco();

    // Executa o cadastro.
    if ($acao === 'cadastro') {
        cadastrar($banco, $entrada, $email, $senha);
    }

    // Executa o login.
    $consulta = $banco->prepare('
        SELECT id, senha_hash, ativo
        FROM usuarios
        WHERE email = ?
    ');

    $consulta->execute([$email]);

    $usuario = $consulta->fetch();

    if (
        !$usuario ||
        (int) $usuario['ativo'] !== 1 ||
        !password_verify(
            $senha,
            $usuario['senha_hash']
        )
    ) {
        responder(401, [
            'erro' => 'E-mail ou senha inválidos.'
        ]);
    }

    // Retorna os dados do usuário autenticado.
    responder(200, [
        'usuario' => buscarConta(
            $banco,
            (int) $usuario['id']
        )
    ]);

} catch (Throwable $erro) {
    error_log(
        'FitHome API: ' .
        get_class($erro) .
        ' (' . $erro->getCode() . ')'
    );

    responder(500, [
        'erro' => 'Não foi possível acessar o FitHome. Tente novamente.'
    ]);
}
