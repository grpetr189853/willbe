# Команди інтерфейсу командного рядку (CLI) [`willbe`](https://github.com/Wandalen/willbe)

В цьому розділі ви можете ознайомитись з доступними командами пакету `willbe`, їх описом та синтаксисом

Всі операції здійснються з допомогою інтерфейсу командного рядка (CLI), який є частиною операційної системи.
Використання пакету [`willbe`](https://github.com/Wandalen/willbe) можливе, лише при його наявності. Операція встановлення здійснюється з допомогою Node Package Manager (npm). Для встановлення введіть команду `npm -g install willbe`. Прапорець `-g` встановлює пакет глобально (доступний з будь-якої директорії). Якщо прапорець `-g` не встановлений, пакет встановлюється локально (доступний тільки в директорії, в якій ви знаходитесь).

Загальний вид синтаксису команд пакету [`willbe`](https://github.com/Wandalen/willbe) має наступну структуру: `will .[command]`, де, `will` вказує на використання пакету `willbe`, префікс команд `.` - особливість роботи пакету, а `[command]` - безпосередньо команда.

## <a name="will-commands"></a>Команди `willbe`
Для виводу всіх доступних команд наберіть `will .` або `will .help`

#### <a name="table"></a> Таблиця. Команди пакету willbe
| Команда           | Опис           | Синтаксис  |
|-------------------|----------------|------------|
| `.help`           | Вивід доступної інформації про команду    | `will .help .[command]`    |
| `.set`            | Встановлення параметрів для will-документа| `will .set [properties]`   |
| `.list`           | Вивід всієї інформації про модуль, в т.ч. готовність завантажених підмодулів і вміст блоків will-файлу                                       | `will .list`      |
| `.paths.list`     | Вивід доступної інформації про шляхи, які прописані в блоці `path` will-файлу                                                      | `will .paths.list`         |
| `.submodules.list`| Вивід доступної інформації про підмодулі, які прописані в блоці `submodule` will-файлу                                                      | `will .submodules.list`    |
| `.reflectors.list`| Вивід доступної інформації про групи файлів, які входять до модуля (підмодулів), зчитана з блоку `reflector` will-файлу                                          | `will .reflectors.list`    |
| `.steps.list`     | Вивід доступної інформації про кроки, які виконуються при виконанні will-файлу, зчитується з блоку `step`                                                          | `will .steps.list`         |
| `.builds.list`    | Вивід доступної інформації про будову модуля та використані кроки для його побудови, зчитується з блоку `build` will-файлу                                        | `will .builds.list`        |
| `.exports.list`   | Вивід доступної інформації про модулі, які доступні для експорту, зчитується з блоку `exported` will-файлу                                                      | `will .exports.list`       |
| `.about.list`     | Вивід інформації про модуль - його назва, версія, автори, тощо. Зчитується з блоку `about` will-файлу                                                      | `will .about.list`         |
| `.execution.list` | Вивід доступної інформації про сценарії створення модулю. Зчитується з блоку `execution` will-файлу                                                      | `will .execution.list`     |
| `.submodules.download`| Завантаження всіх доступних підмодулів згідно блоку `submodule` will-файлу                                                      | `will .submodules.download`|
| `.submodules.upgrade` | Встановлення оновлень для підмодулів, у випадку їх наявності                                                       | `will .submodules.upgrade` |
| `.submodules.clean`   | Видалення з директорії `./modules`завантажених підмодулів                                                      | `will .submodules.clean`   |
| `.clean`          | Видалення з директорії в якій знаходиться модуль 3-х типів файлів 1) завантажені підмодулі (папка `./.module`); 2) out дерикторія; 3) path::temp дерикторія, якщо вона прописана в will-файлі  | `will .clean`              |
| `.clean.what`     | Команда відображає список файлів, які будуть видалені при введені `clean` | `will .clean.what`     |
| `.build`          | Створення модулю відповідно до його опису в will-файлі                    | `will .build`          |
| `.export`         | Особлива форма команди `.build`, яка створює новий will-файл модулю. Цей will-файл може бути використаний як підмодуль іншого модулю ([супермодулю]()).      | `will .export`             |
| `.with`           | Команда дає змогу використовувати [іменовані]() will-файли      | `will .with [module]`      |
| `.each`           | Команда дозволяє застосувати вибрані дії до кожного модулю в директорії  | `will .each .[command]` |

**_Примітка._** Команда виконується, якщо вона синтаксично завершена. Якщо команда складається з двох і більше частин, то при введенні однієї частини команди програма запропонує варіанти доповнення.

<a name="back"></a>
[Повернутись до меню](Topics.md)