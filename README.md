Рекомендую внимательно ознакомиться с этим руководством :)
Разработанное приложение - это файл app1.mlapp. Чтобы его скачать, нужно перейти к этому
файлу и нажать на "download RAW file". Если нужно его просто открыть и нет цели
его редактировать, то просто два раза нажимаем по нему. Сначала откроется матлаб, а потом 
и само приложение (кстати, разрабатывалось оно на версии R2018b, на более старой версии,
скорее всего, не запустится). Если нужно заодно посмотреть и на код и что-то в нем менять,
то сначала открываем матлаб, прописываем в командной строке "appdesigner". В запущенном 
плагине вверху слева находим значок открытия файла, нажимаем на него и затем у себя в файлах
находим мое приложение app1.mlapp. Для запуска нажать на зеленый треугольник с подписью "Run".
После запуска мы видим окошко с тремя кнопками и начальной фразой "выберите изображение". 
Алгоритм пользования программой таков:
 1) Выбираем сначала картинку, ведь без нее ничего не обработается. Для этого нажмем на кнопку
выбора изображения. Затем откроется системное окно для выбора интересующего файла.  
 2) После выбора файла нажимаем на "выделить границы". При первом запуске программа пару
секунд "думает", затем откроется отдельное окно, куда выведется обработанное изображение.
 3) Не закрывая окно для вывода изображения, попробуйте настроить параметры для более точного
выделения границ: 
	- Степень размытия позволяет подавлять мелкие детали. Полезно, если надо выделять 
	только очертания объектов. (чаще всего 2-3 достаточно)
	- Порог выделения границ интерпретирован здесь таким образом, чтобы было удобно 
	подобрать оптимальное значение. Чем выше этот параметр - тем больше границ будет
	обнаружено. (обычно больше 5 можно не вводить, иначе все белым будет)
	- Подавление шумов и немаксимумов - также подавляет мелкие помехи, но не путем размытия
	всего изображения, а путем удаления областей, не связанных с контурами (тоже до 5ти 
	в основном вполне достаточно, иначе может удалить уже полезную часть контура)
	- Тощина границ для улучшения визуального восприятия. Можно в принципе его и не трогать)
	- Оператор в выпадающем списке. Там их всего 5. Можно провести их сравнение (чем я и 
	занимался в этом проекте) 
Каждый раз при изменении параметров не забывайте снова нажимать на "выделить границы".
 4) При достижении результата, который вас удовлетворит, можете сохранить изображение в
выбранную папку. Обратите внимание, что сохранять нельзя, когда вы ничего не обрабатывали.

Про код:
Код программы разделен на 3 метода: метод при нажатии на кнопку обработки изображения (в нем и
лежит алгоритм для выделения границ) и методы для загрузки и сохранения изображения.Эти поля 
редактируемые, поэтому фон у них будет светлее, чем у того кода, который создавался 
автоматически по мере добавления элементов интерфейса.
Весь код, написанный мной, прокомментирован. Надеюсь, что трудностей в понимании он не вызовет)
