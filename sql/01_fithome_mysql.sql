-- FitHOME - MySQL 8.0+ | Estrutura sem alimentacao e hidratacao
CREATE DATABASE IF NOT EXISTS fithome CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE fithome;

-- Credenciais e estado da conta.
CREATE TABLE usuarios (
 id INT AUTO_INCREMENT PRIMARY KEY,
 email VARCHAR(190) NOT NULL UNIQUE,
 senha_hash VARCHAR(255) NOT NULL,
 algoritmo_senha VARCHAR(40) DEFAULT 'bcrypt',
 ativo TINYINT(1) NOT NULL DEFAULT 1,
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Nome, medidas atuais e demais campos de perfil.
CREATE TABLE perfis_usuario (
 usuario_id INT PRIMARY KEY,
 nome_completo VARCHAR(120) NOT NULL,
 data_nascimento DATE,
 genero ENUM('masculino','feminino','outro','prefiro_nao_informar'),
 altura_cm DECIMAL(5,2),
 peso_atual_kg DECIMAL(5,2),
 avatar_url VARCHAR(255),
 biografia TEXT,
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Dados registrados na avaliação inicial.
CREATE TABLE avaliacoes_iniciais (
 id INT AUTO_INCREMENT PRIMARY KEY,
 usuario_id INT NOT NULL,
 avaliado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
 objetivo ENUM('emagrecimento','hipertrofia','condicionamento','saude','outro') NOT NULL,
 nivel_experiencia ENUM('iniciante','intermediario','avancado') NOT NULL,
 lesoes TEXT,
 peso_inicial_kg DECIMAL(5,2),
 gordura_corporal_pct DECIMAL(5,2),
 observacoes TEXT,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Histórico de medidas corporais.
CREATE TABLE metricas_corporais (
 id INT AUTO_INCREMENT PRIMARY KEY,
 usuario_id INT NOT NULL,
 data DATE NOT NULL,
 peso_kg DECIMAL(5,2),
 gordura_pct DECIMAL(5,2),
 torax_cm DECIMAL(5,1),
 cintura_cm DECIMAL(5,1),
 quadril_cm DECIMAL(5,1),
 braco_cm DECIMAL(5,1),
 perna_cm DECIMAL(5,1),
 observacoes VARCHAR(255),
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
 INDEX idx_metricas_usuario_data (usuario_id, data)
) ENGINE=InnoDB;

-- Catálogo de exercícios.
CREATE TABLE exercicios (
 id INT AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(150) NOT NULL,
 descricao TEXT,
 grupo_muscular VARCHAR(80),
 equipamento VARCHAR(120),
 dificuldade ENUM('iniciante','intermediario','avancado'),
 midia_url VARCHAR(255),
 ativo TINYINT(1) NOT NULL DEFAULT 1,
 criado_por INT NULL,
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (criado_por) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Categorias de exercícios.
CREATE TABLE tags_exercicios (
 id INT AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Relacionamento entre exercícios e categorias.
CREATE TABLE exercicio_tags (
 exercicio_id INT NOT NULL,
 tag_id INT NOT NULL,
 PRIMARY KEY (exercicio_id, tag_id),
 FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE CASCADE,
 FOREIGN KEY (tag_id) REFERENCES tags_exercicios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Planos de treino por usuário.
CREATE TABLE planos_treino (
 id INT AUTO_INCREMENT PRIMARY KEY,
 usuario_id INT NOT NULL,
 nome VARCHAR(150) NOT NULL,
 objetivo VARCHAR(120),
 ativo TINYINT(1) NOT NULL DEFAULT 1,
 criado_por INT NULL,
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
 FOREIGN KEY (criado_por) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Ordem e parâmetros dos exercícios de um plano.
CREATE TABLE plano_exercicios (
 id INT AUTO_INCREMENT PRIMARY KEY,
 plano_id INT NOT NULL,
 exercicio_id INT NOT NULL,
 ordem INT NOT NULL,
 series INT NOT NULL,
 repeticoes INT NOT NULL,
 descanso_segundos INT DEFAULT 60,
 observacoes VARCHAR(255),
 FOREIGN KEY (plano_id) REFERENCES planos_treino(id) ON DELETE CASCADE,
 FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE RESTRICT,
 INDEX idx_plano_ordem (plano_id, ordem)
) ENGINE=InnoDB;

-- Histórico de exercícios realizados.
CREATE TABLE registros_treino (
 id INT AUTO_INCREMENT PRIMARY KEY,
 usuario_id INT NOT NULL,
 plano_id INT NULL,
 exercicio_id INT NOT NULL,
 realizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 series_feitas INT,
 repeticoes_feitas INT,
 peso_utilizado_kg DECIMAL(6,2),
 duracao_segundos INT,
 esforco_percebido INT,
 observacoes VARCHAR(255),
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
 FOREIGN KEY (plano_id) REFERENCES planos_treino(id) ON DELETE SET NULL,
 FOREIGN KEY (exercicio_id) REFERENCES exercicios(id) ON DELETE RESTRICT,
 INDEX idx_registros_usuario_data (usuario_id, realizado_em)
) ENGINE=InnoDB;

-- Temas disponíveis.
CREATE TABLE temas (
 id SMALLINT AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(50) NOT NULL UNIQUE,
 configuracoes JSON
) ENGINE=InnoDB;

-- Preferências de idioma, tema e notificações.
CREATE TABLE preferencias_usuario (
 usuario_id INT PRIMARY KEY,
 tema_id SMALLINT NULL,
 idioma VARCHAR(10) DEFAULT 'pt-BR',
 fuso_horario VARCHAR(50) DEFAULT 'America/Sao_Paulo',
 unidades ENUM('metrico','imperial') DEFAULT 'metrico',
 notificacoes_ativas TINYINT(1) DEFAULT 1,
 modo_escuro TINYINT(1) DEFAULT 0,
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
 FOREIGN KEY (tema_id) REFERENCES temas(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Histórico de aceite dos termos.
CREATE TABLE aceite_termos (
 id INT AUTO_INCREMENT PRIMARY KEY,
 usuario_id INT NOT NULL,
 versao_termos VARCHAR(50) NOT NULL,
 aceito_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 ip VARCHAR(45),
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Sessões e seus prazos de expiração.
CREATE TABLE sessoes_autenticacao (
 id INT AUTO_INCREMENT PRIMARY KEY,
 usuario_id INT NOT NULL,
 token_hash CHAR(64) NOT NULL UNIQUE,
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 expira_em TIMESTAMP NOT NULL,
 ip VARCHAR(45),
 dispositivo VARCHAR(255),
 revogado_em TIMESTAMP NULL,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Notificações e histórico de envio.
CREATE TABLE notificacoes (
 id INT AUTO_INCREMENT PRIMARY KEY,
 usuario_id INT NOT NULL,
 tipo VARCHAR(50) NOT NULL,
 titulo VARCHAR(120) NOT NULL,
 corpo TEXT,
 canal ENUM('app','email','push') DEFAULT 'app',
 agendado_para DATETIME NULL,
 enviado_em DATETIME NULL,
 lido_em DATETIME NULL,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Chamados de suporte.
CREATE TABLE chamados_suporte (
 id INT AUTO_INCREMENT PRIMARY KEY,
 usuario_id INT NOT NULL,
 titulo VARCHAR(150) NOT NULL,
 mensagem TEXT NOT NULL,
 status ENUM('aberto','em_andamento','resolvido','fechado') DEFAULT 'aberto',
 prioridade ENUM('baixa','media','alta') DEFAULT 'media',
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 admin_responsavel INT NULL,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
 FOREIGN KEY (admin_responsavel) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Histórico de ações administrativas.
CREATE TABLE auditoria_admin (
 id INT AUTO_INCREMENT PRIMARY KEY,
 admin_id INT NULL,
 acao VARCHAR(80) NOT NULL,
 tabela_alvo VARCHAR(80),
 alvo_id INT,
 detalhes JSON,
 criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 ip VARCHAR(45),
 FOREIGN KEY (admin_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Papéis de acesso.
CREATE TABLE papeis (
 id INT AUTO_INCREMENT PRIMARY KEY,
 nome VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Relacionamento entre usuários e papéis.
CREATE TABLE usuarios_papeis (
 usuario_id INT NOT NULL,
 papel_id INT NOT NULL,
 atribuido_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (usuario_id, papel_id),
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
 FOREIGN KEY (papel_id) REFERENCES papeis(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Dados iniciais de papéis e temas.
INSERT INTO papeis (nome) VALUES ('usuario'), ('administrador');
INSERT INTO temas (nome, configuracoes) VALUES ('claro', JSON_OBJECT('modo', 'light')), ('escuro', JSON_OBJECT('modo', 'dark'));
