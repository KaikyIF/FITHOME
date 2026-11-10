<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');

// Traduz as opções exibidas no Flutter para os valores armazenados no banco.
const GOALS = [
    'Perder Peso' => 'emagrecimento',
    'Ganhar Massa' => 'hipertrofia',
    'Melhorar Saúde' => 'saude',
    'Ganhar Flexibilidade' => 'flexibilidade',
];
// Mantém os níveis da interface alinhados ao ENUM do MySQL.
const LEVELS = [
    'Iniciante' => 'iniciante',
    'Intermediário' => 'intermediario',
    'Avançado' => 'avancado',
];
// Lista as condições que podem ser enviadas no cadastro.
const CONDITIONS = [
    'Nenhuma', 'Problemas cardíacos', 'Diabetes', 'Pressão alta',
    'Problemas articulares', 'Problemas respiratórios', 'Gravidez', 'Lesão recente',
];

// Envia a resposta em JSON e encerra o processamento da requisição.
function reply(int $status, array $body): never
{
    http_response_code($status);
    echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
    exit;
}

// Responde a um formulário válido em JSON, mas com campos inválidos.
function invalid(string $message): never
{
    reply(422, ['erro' => $message]);
}

// Valida medidas numéricas e arredonda para a precisão das colunas.
function decimal(array $input, string $key, float $min, float $max, string $message): float
{
    $value = $input[$key] ?? null;
    if (!is_int($value) && !is_float($value)) {
        invalid($message);
    }
    if (!is_finite((float) $value) || $value < $min || $value > $max) {
        invalid($message);
    }
    return round($value, 2);
}

// Abre a conexão usando as credenciais configuradas no servidor.
function database(): PDO
{
    $host = getenv('DB_HOST') ?: '127.0.0.1';
    $port = getenv('DB_PORT') ?: '3306';
    $name = getenv('DB_NAME') ?: 'fithome';
    $user = getenv('DB_USER');
    $pass = getenv('DB_PASSWORD');
    if ($user === false || $pass === false) {
        throw new RuntimeException('Configure DB_USER e DB_PASSWORD no servidor.');
    }

    return new PDO("mysql:host=$host;port=$port;dbname=$name;charset=utf8mb4", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_EMULATE_PREPARES => false,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
}

// Carrega o perfil e a avaliação mais recente para devolver ao Flutter.
function account(PDO $db, int $id): array
{
    $query = $db->prepare('
        SELECT u.id, u.email, p.nome_completo, p.altura_cm, p.peso_atual_kg,
               a.idade_anos, a.imc, a.objetivo, a.nivel_experiencia, a.condicoes_saude
        FROM usuarios u
        LEFT JOIN perfis_usuario p ON p.usuario_id = u.id
        LEFT JOIN avaliacoes_iniciais a ON a.id = (
            SELECT ai.id FROM avaliacoes_iniciais ai
            WHERE ai.usuario_id = u.id ORDER BY ai.avaliado_em DESC, ai.id DESC LIMIT 1
        )
        WHERE u.id = ?
    ');
    $query->execute([$id]);
    $row = $query->fetch();
    $goals = GOALS + ['Ganhar Resistência' => 'condicionamento', 'Outro' => 'outro'];

    return [
        'id' => (int) $row['id'],
        'nome' => $row['nome_completo'] ?? '',
        'email' => $row['email'],
        'idade' => $row['idade_anos'] === null ? null : (int) $row['idade_anos'],
        'altura' => $row['altura_cm'] === null ? null : (float) $row['altura_cm'],
        'peso' => $row['peso_atual_kg'] === null ? null : (float) $row['peso_atual_kg'],
        'imc' => $row['imc'] === null ? null : (float) $row['imc'],
        'objetivo' => array_search($row['objetivo'], $goals, true) ?: 'Perder Peso',
        'nivel' => array_search($row['nivel_experiencia'], LEVELS, true) ?: 'Iniciante',
        'condicoes_saude' => $row['condicoes_saude'] === null
            ? [] : json_decode($row['condicoes_saude'], true, 512, JSON_THROW_ON_ERROR),
    ];
}

// Valida o cadastro e grava usuário, perfil e avaliação juntos.
function register(PDO $db, array $input, string $email, string $password): never
{
    $name = is_string($input['nome'] ?? null) ? trim($input['nome']) : '';
    if (!preg_match('/\A.{1,120}\z/u', $name)) {
        invalid('Informe um nome com até 120 caracteres.');
    }
    if (preg_match_all('/./us', $password) < 6) {
        invalid('A senha precisa ter pelo menos 6 caracteres.');
    }
    $age = $input['idade'] ?? null;
    if (!is_int($age) || $age < 1 || $age > 120) {
        invalid('Informe uma idade entre 1 e 120 anos.');
    }
    $height = decimal($input, 'altura', 30, 300, 'Informe uma altura entre 30 e 300 cm.');
    $weight = decimal($input, 'peso', 1, 999.99, 'Informe um peso entre 1 e 999,99 kg.');
    $goal = $input['objetivo'] ?? null;
    $level = $input['nivel'] ?? null;
    if (!is_string($goal) || !isset(GOALS[$goal]) || !is_string($level) || !isset(LEVELS[$level])) {
        invalid('Selecione um objetivo e um nível válidos.');
    }
    $conditions = $input['condicoes_saude'] ?? null;
    if (!is_array($conditions) || !array_is_list($conditions) || count($conditions) < 1
        || count($conditions) > count(CONDITIONS)
        || (count($conditions) > 1 && in_array('Nenhuma', $conditions, true))) {
        invalid('Selecione condições de saúde válidas ou marque Nenhuma.');
    }
    foreach ($conditions as $condition) {
        if (!in_array($condition, CONDITIONS, true)) {
            invalid('Selecione uma condição de saúde válida.');
        }
    }
    $conditionsJson = json_encode(array_values(array_unique($conditions)), JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
    // Recalcula o IMC a partir das mesmas medidas gravadas no MySQL.
    $bmi = round($weight / (($height / 100) ** 2), 2);
    $hash = password_hash($password, PASSWORD_BCRYPT);

    // Qualquer falha desfaz as três gravações do cadastro.
    $db->beginTransaction();
    try {
        $db->prepare('INSERT INTO usuarios (email, senha_hash, algoritmo_senha) VALUES (?, ?, ?)')
            ->execute([$email, $hash, 'bcrypt']);
        $id = (int) $db->lastInsertId();
        $db->prepare('INSERT INTO perfis_usuario (usuario_id, nome_completo, altura_cm, peso_atual_kg) VALUES (?, ?, ?, ?)')
            ->execute([$id, $name, $height, $weight]);
        $db->prepare('
            INSERT INTO avaliacoes_iniciais
                (usuario_id, idade_anos, imc, objetivo, nivel_experiencia, condicoes_saude, peso_inicial_kg)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ')->execute([$id, $age, $bmi, GOALS[$goal], LEVELS[$level], $conditionsJson, $weight]);
        $result = account($db, $id);
        $db->commit();
    } catch (Throwable $error) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        if ($error instanceof PDOException && ($error->errorInfo[1] ?? null) === 1062) {
            reply(409, ['erro' => 'Este e-mail já está cadastrado. Volte ao login para entrar.']);
        }
        throw $error;
    }

    reply(201, ['usuario' => $result]);
}

// Restringe a API às ações POST de cadastro e login.
if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    header('Allow: POST');
    reply(405, ['erro' => 'Use POST.']);
}
$action = $_GET['acao'] ?? '';
if (!in_array($action, ['cadastro', 'login'], true)) {
    reply(404, ['erro' => 'Ação não encontrada.']);
}

try {
    $body = file_get_contents('php://input', false, null, 0, 16385);
    if ($body === false || strlen($body) > 16384) {
        reply(413, ['erro' => 'Requisição muito grande.']);
    }
    try {
        $input = json_decode($body, true, 16, JSON_THROW_ON_ERROR);
    } catch (JsonException) {
        reply(400, ['erro' => 'Envie um JSON válido.']);
    }
    if (!is_array($input) || array_is_list($input)) {
        reply(400, ['erro' => 'Envie um objeto JSON.']);
    }
    $email = is_string($input['email'] ?? null) ? strtolower(trim($input['email'])) : '';
    $password = $input['senha'] ?? null;
    if (strlen($email) > 190 || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        invalid('Informe um e-mail válido.');
    }
    if (!is_string($password) || $password === '' || strlen($password) > 72 || str_contains($password, "\0")) {
        invalid('Informe uma senha válida de até 72 bytes.');
    }

    $db = database();
    if ($action === 'cadastro') {
        register($db, $input, $email, $password);
    }

    // Confere a senha sem devolver o hash ao aplicativo.
    $query = $db->prepare('SELECT id, senha_hash, ativo FROM usuarios WHERE email = ?');
    $query->execute([$email]);
    $user = $query->fetch();
    if (!$user || (int) $user['ativo'] !== 1 || !password_verify($password, $user['senha_hash'])) {
        reply(401, ['erro' => 'E-mail ou senha inválidos.']);
    }
    reply(200, ['usuario' => account($db, (int) $user['id'])]);
} catch (Throwable $error) {
    error_log('FitHome API: ' . get_class($error) . ' (' . $error->getCode() . ')');
    reply(500, ['erro' => 'Não foi possível acessar o FitHome. Tente novamente.']);
}
