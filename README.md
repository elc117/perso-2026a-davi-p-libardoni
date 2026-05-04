# Backend Web com Haskell+Scotty

COMMIT HISTORY ESTÁ NO REPOSITÓRIO A SEGUIR:
https://github.com/davi-p-libardoni/readLog

## 1. Identificação

- Nome: Davi Paiani Libardoni
- Curso: Sistemas de Informação

---

## 2. Tema/objetivo

O projeto se trata de um backlog de leituras, sistema onde você registra os livros que leu, em que datas, e pode ver estatísticas de acordo com esses registros.
A programação funcional realiza o trabalho de filtragem, ordenação e acumulação dos dados, além do cálculo das estatísticas como páginas lidas por mês.

---

## 3. Processo de desenvolvimento

Ao longo do processo de desenvolvimento, tive que dar uma reduzida no meu escopo inicial. Percebi que algumas funcionalidades que eu havia planejado seriam muito difíceis de implementar, e tive que simplificar. Por exemplo, a estatística de "páginas lidas por mês" tive que fazer de maneira bem simplificada, conta todas as páginas do livro no mês em que foi completo.
Outra dificuldade que tive foi com a passagem de dados do backend (haskell) pro frontend (html), com conversões do meu tipo de dados Book do haskell para objeto JSON, e conversões de linhas do banco de dados para esse meu tipo Book também foram difíceis.
Funções puras que usei muito foram filter, map, e funções específicas da biblioteca de tempo do haskell, como toGregorian, para lidar com datas, além de sortBy, função de ordenação de listas. Também utilizei pattern matching para 

Comecei o desenvolvimento pelas funções puras, depois fazendo o arquivo de testes. De início, tentei fazer deploy no render cedo, porém não consegui pois a cada erro de compilação eu perdia 5 minutos esperando o Render acusar o erro. Então decidi implementar todo o projeto localmente primeiro, pra depois tentar o deploy, e essa estratégia funcionou.
Depois, pelo Render, criei um banco de dados PostgreSQL para o armazenamento dos livros lidos, e criei uma chave de API do Google Books para buscar os livros por nome.
Tanto a chave da API quanto as credenciais do banco de dados foram adicionadas como variáveis de ambiente no Render, e variáveis de ambiente no computador local.

A princípio, usei a IA para fazer filtragens e ordenações simples via javascript client-side na página inicial, a fim de ver como ficaria o site funcionando. Mais à frente, substituí esses funcionamentos pelos meus feitos em Haskell por meio de parâmetros nas rotas GET do scotty.

---

## 4. Testes

Para os testes, utilizei HUnit. Utilizei uma lista de exemplo de instâncias do meu tipo Book, e com essa lista testei as funções de ordenação, filtragem e estatísticas (filtrar por autor, ordenar por lidos mais recentemente, etc.)
Para executar os testes, basta rodar "stack test"

---

## 5. Execução

Para executar localmente, é preciso ter instalado o GHC e o Stack. Além disso, é preciso definir algumas variáveis de ambiente, que na minha implementação final são inseridas pelo próprio Render, para manter a segurança das chaves de API e credenciais do banco de dados.
Para isso, executa-se no terminal os comandos:
$ENV:DATABASE_URL="..."
$ENV:PORT=3000
$ENV:GOOGLE_BOOKS_API_KEY="..."

Infelizmente não consegui fazer um jeito do sistema rodar sem um banco de dados, então não vai ser possível executar localmente sem um banco de dados acessível, e não posso commitar essas credenciais no GitHub, então as próximas etapas dessa seção vão explicar como seria executado se essas variáveis estivessem definidas.
Apesar disso, o serviço deve estar online no Render, então é possível acessar pelo link escrito na próxima seção.

Após isso, utiliza-se o comando "stack build" e depois "stack run", e o stack instala as dependências necessárias.
Após a execução desses comandos, basta acessar "https://localhost:3000"

---

## 6. Deploy

Link do serviço publicado: https://readlog.onrender.com/

O deploy foi relativamente tranquilo. Tive uma dificuldade com a rota do endereço base para o arquivo html que estava dentro da pasta static/ na root do projeto, visto que quando estava rodando em localhost, era só usar 'file "/static/readlog.html"', e no render tive que adicionar uma variável de ambiente dentro do Dockerfile que aponta para a pasta static, já que o Render não parece partir da root.

---

## 7. Resultado final

<img width="1895" height="866" alt="Animação" src="https://github.com/user-attachments/assets/37904520-fe85-4ae8-bcf7-651b1ed18ad6" />

Gif mostrando a inserção de um livro no log.

---

## 8. Uso de IA 

### 8.1 Ferramentas de IA utilizadas

GitHub Copilot com ChatGPT-5.2 Codex, Claude Sonnet 4.6 

---

### 8.2 Interações relevantes com IA

#### Interação 1

- **Objetivo da consulta:**
Criação de um frontend responsivo

- **Trecho do prompt ou resumo fiel:**
Create a high-fidelity landing page for a Reading Backlog Manager web application using HTML5, CSS3 (Flexbox/Grid), and Vanilla JavaScript.

Após esse trecho, incluí uma lista de requisitos, não vou colocar todos para ser breve.

The interface should include:

    A Sticky Navigation Bar: Featuring a logo, a search bar for the library, and an 'Add New Book' button.
    A Dynamic Hero Section: Highlighting the 'Current Read' with a progress bar and a 'Days Remaining' estimate.
    [...]

- **O que foi aproveitado:**  
O resultado foi satisfatório, quase toda a interface foi aproveitada.

- **O que foi modificado ou descartado:**  
Algumas das escolhas estilísticas do agente não foram tão boas e eu as removi, como a hero section sendo "sticky" com uma animação que não permitia ver a lista de livros lidos sem scrollar algumas vezes.


#### Interação 2

- **Objetivo da consulta:**
Fazer o parsing de JSON e Row do banco de dados para o meu tipo de dados Book, e vice-versa, visto que esses parsings utilizam sintaxes que eu não conhecia e não conseguia entender, como uso de <$> e <*>

- **Trecho do prompt ou resumo fiel:**  
I want to send a post request containing a JSON object with information about a book, how to parse that json in Main.hs in order to send it to the database

- **O que foi aproveitado:**
Consegui entender o funcionamento do código, por mais que eu ainda não tenha conseguido entender a teoria por trás (functors, funções aplicativas).

- **O que foi modificado ou descartado:**
Nesse caso, nada.

#### Interação 3 

- **Objetivo da consulta:**
Pedi ajuda ao Copilot para tentar entender algumas funções que vi em exemplos de código do Scotty.

- **Trecho do prompt ou resumo fiel:**  
Explain liftIO and ActionM keywords used in these examples of Scotty code: (print de trechos de código)

- **O que foi aproveitado:**  
Consegui entender como utilizar essas funções efetivamente.

- **O que foi modificado ou descartado:**
Não fui capaz de entender os termos técnicos e como essas funções funcionam por trás dos panos, visto que as type signatures eram muito complexas e os termos teóricos muito complicados (Monad Transformer stack, por exemplo)


### 8.3 Exemplo de erro, limitação ou sugestão inadequada da IA

Em um momento, pedi ao Claude se havia um jeito de passar um parâmetro que indicasse um mês de um ano específico (ex: Janeiro de 2024). Ele me indicou o tipo YearMonth da biblioteca Time.Calendar.Month, porém esse tipo não existia, ele alucinou essa funcionalidade. No final das contas, decidi mandar o mês e o ano como argumentos separados.

---

### 8.4 Comentário pessoal sobre o processo envolvendo IA

O uso da IA ajudou muito a focar na parte importante, as funções puras do Haskell e o funcionamento do Scotty, podendo relegar as tarefas mais "busy work" como implementação e estilização do frontend aos agentes.

Consegui entender melhor sobre o funcionamento de where e let na prática por meio de trechos de código explicados pelo Copilot, visto que eu ainda não havia feito um trecho let dentro de um bloco where.

Ainda me sinto limitado quanto as mônadas. Pra ser sincero, eu consegui entender até certo ponto a teoria por trás, mas não consegui compreender quase nada da prática, mesmo com explicações do Claude.

---

## 9. Referências e créditos

Em grande parte, aprendi sobre o framework Scotty e bibliotecas Haskell com prompts ao Claude Sonnet e Github Copilot


Link ao repositório com commit history:
https://github.com/davi-p-libardoni/readLog
