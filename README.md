# FITHOME
## 1. APRESENTAÇÃO DO SOFTWARE
O FitHome é uma plataforma pensada para tornar os exercícios físicos mais
acessíveis e personalizados, ajudando as pessoas a manterem um estilo de vida
saudável sem sair de casa. O nome foi escolhido para refletir a ideia de unir o
conceito de fitness com a praticidade do lar, permitindo que qualquer pessoa,
independentemente de sua rotina ou limitações, consiga se exercitar com eficiência.
A proposta do FitHome é oferecer treinos feitos sob medida para cada usuário, seja
ele iniciante ou mais experiente, adaptando-se ao seu nível de condicionamento
físico e seus objetivos. O que realmente diferencia o FitHome de outros aplicativos é
o foco na personalização contínua dos planos de treino, que evoluem à medida que
o usuário avança. O objetivo é que o
FitHome ajude a transformar a vida de seus usuários, melhorando não só a saúde
física, mas também o bem-estar mental, promovendo hábitos saudáveis de forma
simples, prática e adaptada ao dia a dia de cada um, sem que seja preciso sair de
casa.

O cadastro é enviado ao tocar em **Começar a Treinar**. O botão **Entrar** consulta a API e valida a senha cadastrada. Cada vez que o aplicativo é aberto, ele pede o login novamente. As alterações de objetivo e nível feitas depois pelo menu Perfil são locais à sessão nesta versão.

## Abrir no VS Code

Abra a pasta `FitHome` que contém `pubspec.yaml`. As 15 telas ficam em `lib/screens/`, com uma classe por arquivo. Os componentes reaproveitados ficam em `lib/widgets/`. `lib/main.dart` controla a navegação e a sessão, e `lib/account_api.dart` faz as chamadas HTTP.

## Subir a API e um banco de teste

Na pasta que contém o arquivo `compose.yaml`, com Docker Desktop aberto:

```powershell
docker compose up --build -d
docker compose ps
```

A API fica em `http://localhost:8088/api.php` por padrão. O banco fica na rede interna do Compose e mantém os dados no volume `dados_mysql`. O primeiro início de um volume vazio aplica os dois SQLs da pasta `sql`. O Compose é para desenvolvimento local. As variáveis `FITHOME_DB_PASSWORD` e `FITHOME_DB_ROOT_PASSWORD` permitem definir senhas próprias antes de criar o volume. A variável `FITHOME_PORT` altera a porta da API.

## Usar um banco FitHome existente

Aplique **apenas** `sql/02_cadastro.sql` uma vez no MySQL 8.0+ após selecionar o banco FitHome existente. A migração acrescenta idade, IMC e condições de saúde à avaliação e inclui o valor de flexibilidade na lista de objetivos. Se o banco estiver vazio, importe primeiro `sql/01_fithome_mysql.sql`. O Compose usa seu próprio banco.

A API está em um único arquivo, `api/api.php`. Para hospedá-la com PHP 8.4 e `pdo_mysql`, defina no servidor `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` e `DB_PASSWORD`. O usuário MySQL precisa de SELECT e INSERT em `usuarios`, `perfis_usuario` e `avaliacoes_iniciais`. As credenciais do banco ficam no servidor. Use HTTPS para o app em produção.

## Rodar o app

O projeto inclui Android. Com o SDK do Android configurado no Flutter e um emulador aberto:

```powershell
flutter pub get
flutter run
```

No emulador Android padrão, o app usa `http://10.0.2.2:8088/api.php`. Para usar um celular Android na mesma rede, primeiro exponha a porta da API na interface de rede do computador:

```powershell
$env:FITHOME_BIND = '0.0.0.0'
docker compose up -d
flutter run --dart-define=FITHOME_API_URL=http://192.168.1.10:8088/api.php
```

Troque `192.168.1.10` pelo IP local do computador. O manifesto Android permite HTTP apenas no build de depuração. Para iOS, gere a plataforma com `flutter create . --platforms ios` e configure o endereço HTTPS com `FITHOME_API_URL`.

## O que é gravado

- `usuarios` guarda o e-mail e o hash bcrypt da senha.
- `perfis_usuario` guarda nome, altura em centímetros e peso em quilos.
- `avaliacoes_iniciais` guarda idade em anos na data do cadastro, IMC, objetivo, nível, condições de saúde e peso inicial.

O servidor recalcula o IMC com as medidas gravadas e salva as três tabelas em uma transação. A idade é gravada diretamente porque o formulário pede idade em anos. As condições de saúde ficam em uma lista JSON na avaliação. O cadastro não cria registros de treino, métricas históricas ou notificações.

### Contrato da API

Envie JSON por POST. Use `api.php?acao=cadastro` com `nome`, `email`, `senha`, `idade`, `altura`, `peso`, `objetivo`, `nivel` e `condicoes_saude`. Envie idade, altura e peso como números, e as condições como uma lista das opções exibidas no formulário. Use `api.php?acao=login` com `email` e `senha`. O cadastro responde 201 e o login responde 200 com um objeto `usuario`. A API nunca devolve o hash da senha.
