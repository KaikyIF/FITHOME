-- Rode uma vez em um banco FitHome que já tenha a estrutura original.
USE fithome;

-- As colunas permitem NULL para preservar avaliações criadas antes da migração.
-- A idade registra os anos informados no cadastro. O IMC usa duas casas decimais e as condições ficam em uma lista JSON.
ALTER TABLE avaliacoes_iniciais
    ADD COLUMN idade_anos TINYINT UNSIGNED NULL,
    ADD COLUMN imc DECIMAL(8,2) UNSIGNED NULL,
    ADD COLUMN condicoes_saude JSON NULL,
    MODIFY COLUMN objetivo ENUM('emagrecimento','hipertrofia','condicionamento','saude','outro','flexibilidade') NOT NULL;
