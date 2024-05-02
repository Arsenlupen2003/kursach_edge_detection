classdef app1 < matlab.apps.AppBase % Инициализация элементов интерфейса
 % Properties that correspond to app components
 properties (Access = public)
 InputParametersUIFigure matlab.ui.Figure
 Button matlab.ui.control.Button
 Label matlab.ui.control.Label
 EditField matlab.ui.control.NumericEditField
 Label_2 matlab.ui.control.Label
 EditField_2 matlab.ui.control.NumericEditField
 Button_2 matlab.ui.control.Button
 Label_3 matlab.ui.control.Label
 Button_3 matlab.ui.control.Button
 Label_4 matlab.ui.control.Label
 EditField_3 matlab.ui.control.NumericEditField
 Label_5 matlab.ui.control.Label
 EditField_4 matlab.ui.control.NumericEditField
 Label_6 matlab.ui.control.Label
 DropDown matlab.ui.control.DropDown
 end
 methods (Access = private)
 % Button pushed function: Button (листинг алгоритма выделения границ)
 function ButtonPushed(app, event)
 % Инициализируем глобальные переменные
 global img;
 global edgeImg;
 % save будет принимать значение 1, когда обработка будет произведена успешно
 global save;
 % Процесс обработки изображения начнется, если переменная img не будет пуста
 if (~isnan(img))
 if(ndims(img) == 3)
 % Преобразование изображения в оттенки серого если оно цветное
 grayImg = rgb2gray(img);
 else
 % Переменная grayImg есть img, если исходная картинка полутоновая
 grayImg = img;
 end
 % Увеличение размера изображения для более точной обработки
 if size(grayImg) < 2000
 % Увеличение изображения в 2 раза, если оно меньше 2000 пикселей
 grayImg = imresize(grayImg, 2);
 end
 % Переменные для регулировки границ, вводимые пользователем
 gau = app.EditField.Value;
 tr = app.EditField_2.Value;
 nm = app.EditField_3.Value;
 ed = app.EditField_4.Value;
44
 del = round(nm * 6);
 % Сглаживание изображения фильтром Гаусса
 smoothImg = imgaussfilt(grayImg, gau);
 if(app.DropDown.Value == "Собеля")
 % Операторы Собеля для вычисления градиентов
 sobelVertical = [-1, -2, -1; 0, 0, 0; 1, 2, 1];
 sobelHorizontal = [-1, 0, 1; -2, 0, 2; -1, 0, 1];
 % Применение операторов Собеля к изображению
 gradX = conv2(double(smoothImg), sobelHorizontal, 'same');
 gradY = conv2(double(smoothImg), sobelVertical, 'same');
 % Вычисление общего градиента и направления
 gradMag = sqrt(gradX.^2 + gradY.^2);
 elseif (app.DropDown.Value == "Робертса")
 % Операторы Робертса для вычисления градиентов
 h_roberts_x = [1, 0; 0, -1];
 h_roberts_y = [0, 1; -1, 0];
 % Применение операторов Робертса к изображению
 grad_x = conv2(double(smoothImg), h_roberts_x, 'same');
 grad_y = conv2(double(smoothImg), h_roberts_y, 'same');
 % Вычисление общего градиента
 gradMag = sqrt(grad_x.^2 + grad_y.^2);
 % Выравнивание параметров предотвращения повторной настройки
 elseif(app.DropDown.Value == "Превитта")
 % Операторы Превитта для вычисления градиентов
 PrewX = [-1, -1, -1; 0, 0, 0; 1, 1, 1];
 PrewY = [-1, 0, 1; -1, 0, 1; -1, 0, 1];
 % Применение операторов Превитта к изображению
 gradX = conv2(double(smoothImg), PrewX, 'same');
 gradY = conv2(double(smoothImg), PrewY, 'same');
 % Вычисление общего градиента и направления
 gradMag = sqrt(gradX.^2 + gradY.^2);
 elseif (app.DropDown.Value == "Шарра")
 % Определение операторов Шарра
 sharX = [-3 0 3; -10 0 10; -3 0 3];
 sharY = [-3 -10 -3; 0 0 0; 3 10 3];
 % Применение операторов Шарра
 grad_x = conv2(double(smoothImg), sharX, 'same');
 grad_y = conv2(double(smoothImg), sharY, 'same');
 % Вычисление градиента магнитуды
 gradMag = sqrt(grad_x.^2 + grad_y.^2);
 elseif (app.DropDown.Value == "Кирша")
 % Определение операторов Кирша для 8 направлений
 KirschMasks = {
 [5 5 5; -3 0 -3; -3 -3 -3]
 [-3 5 5; -3 0 5; -3 -3 -3]
 [-3 -3 5; -3 0 5; -3 -3 5]
 [-3 -3 -3; -3 0 5; -3 5 5]
 [-3 -3 -3; -3 0 -3; 5 5 5]
 [-3 -3 -3; 5 0 -3; 5 5 -3]
 [5 -3 -3; 5 0 -3; 5 -3 -3]
 [5 5 -3; 5 0 -3; -3 -3 -3]
 };
45
 gradSum = 0;
 for i = 1:length(KirschMasks)
 % Применение операторов Кирша
 grad = conv2(double(smoothImg), KirschMasks{i}, 'same');
 gradSum = grad.^2+gradSum;
 end
 % Градиент магнитуды
 gradMag = sqrt(gradSum);
 end
 % Нормализация значений яркости
 gradMag = ((gradMag / max(gradMag(:))) * 255);
 % Подавление немаксимумов
 nmsImg = imhmax(gradMag, 3*nm);
 % Применение порога для регулировки границ
 tresh = 0.1/tr * 255;
 ThreshImg = nmsImg >= tresh;
 % Утончение границ
 ThinImg = bwmorph(ThreshImg, 'thin', inf);
 % Удаление изолированных пикселей
 DenoisedImg = bwareaopen(ThinImg, del);
 % Утолщение границ для лучшего визуального восприятия
 edgeImg = imdilate(DenoisedImg, strel('disk', ed));
 % Вывод результатов
 subplot(1,2,1), imshow(img), title('Исходное изображение');
 subplot(1,2,2), imshow(edgeImg), title('Результат выделения границ');
 app.Label_3.Text = ('Готово!');
 % Переменную save приравниваем к 1, т.к. процесс обработки прошел успешно
 save = 1;
 else
 % Если переменная img будет пуста (когда не выбран файл)
 app.Label_3.Text = ('Сначала выберите изображение');
 % Приравниваем save к нулю, так как нечего обрабатывать
 save = 0;
 end
 end
 % Button pushed function: Button_2 (листинг алгоритма загрузки изображения)
 function Button_2Pushed(app, event)
 global img;
 global save;
 % Переменная ext возвращает значение индекса матрицы разрешенных форматов
 [filename, pathname, ext] = uigetfile({'*.jpg';'*.png';'*.jpeg'}, 'Выберите изображение');
 % Если выбор изображения был отменен
 if isequal(filename,0) || isequal(pathname,0)
 app.Label_3.Text = ('Изображение не выбрано. Повторите попытку');
 % Разыменование img, поскольку файл не выбран
 img = nan;
 % save приравниваем к 0, так как файл не был выбран
 save = 0;
 return;
 end
 
46
% Переменная ext возвращает индекс элемента из матрицы разрешенных форматов
 if (ext == 1 || ext == 2 || ext == 3)
 img = imread(fullfile(pathname, filename));
 app.Label_3.Text = ('Теперь нажмите "Выделить границы"');
 return;
 else
 % При выборе неразрешенного формата ext вернет другое значение
 app.Label_3.Text = ('Выбран неверный тип файла');
 % Разыменование img, поскольку выбран неверный формат
 img = nan;
 % save приравниваем к 0, так как был выбран неверный формат
 save = 0;
 end
 end
 % Button pushed function: Button_3 (листинг алгоритма сохранения результата)
 function Button_3Pushed(app, event)
 global save;
 global edgeImg;
 % Если save будет равен 1, тогда можно будет сохранить файл
 if save == 1
 % Запрос на выбор папки
 folder_name = uigetdir;
 % Сохранение изображения в выбранной папке
 if folder_name ~= 0 % Если папка была выбрана
 [~, baseFileName, ext] = fileparts('example.jpg');
 fullFileName = fullfile(folder_name, [baseFileName, ext]);
 imwrite(edgeImg, fullFileName); % Сохранение изображения
 app.Label_3.Text = (['Изображение сохранено в папке: ', fullFileName]);
 else
 % Иначе папка не выбрана и возможность сохранить будет недоступна 
 app.Label_3.Text = ('Сохранение отменено');
 end
 else
 % Если save равен другому значению (нулю), сохранение будет невозможно
 app.Label_3.Text = ('Для сохранения сначала нужно выделить границы');
 end
 end
 end
 % App initialization and construction (инициализация параметров интерфейса)
 methods (Access = private)
 % Create UIFigure and components
 function createComponents(app)
 % Create InputParametersUIFigure
 app.InputParametersUIFigure = uifigure;
 app.InputParametersUIFigure.Color = [0.8314 0.9294 0.9804];
 app.InputParametersUIFigure.Position = [100 100 524 288];
 app.InputParametersUIFigure.Name = 'InputParameters';
 app.InputParametersUIFigure.Resize = 'off';
47
 % Create Button
 app.Button = uibutton(app.InputParametersUIFigure, 'push');
 app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
 app.Button.BackgroundColor = [0.949 0.9176 0.7804];
 app.Button.FontName = 'Comic Sans MS';
 app.Button.FontSize = 14;
 app.Button.FontColor = [0 0.451 0.7412];
 app.Button.Position = [184 19 157 50];
 app.Button.Text = 'Выделить границы';
 % Create Label
 app.Label = uilabel(app.InputParametersUIFigure);
 app.Label.FontName = 'Comic Sans MS';
 app.Label.FontSize = 14;
 app.Label.FontColor = [0 0.451 0.7412];
 app.Label.Position = [19 194 215 22];
 app.Label.Text = 'Степень размытия (от 0.1 до 5)';
 % Create EditField
 app.EditField = uieditfield(app.InputParametersUIFigure, 'numeric');
 app.EditField.Limits = [0.1 5];
 app.EditField.FontName = 'Comic Sans MS';
 app.EditField.Position = [467 194 40 22];
 app.EditField.Value = 1;
 % Create Label_2
 app.Label_2 = uilabel(app.InputParametersUIFigure);
 app.Label_2.FontName = 'Comic Sans MS';
 app.Label_2.FontSize = 14;
 app.Label_2.FontColor = [0 0.451 0.7412];
 app.Label_2.Position = [19 160 273 22];
 app.Label_2.Text = 'Порог выделения границ (от 0.1 до 10)';
 % Create EditField_2
 app.EditField_2 = uieditfield(app.InputParametersUIFigure, 'numeric');
 app.EditField_2.Limits = [0.1 10];
 app.EditField_2.FontName = 'Comic Sans MS';
 app.EditField_2.Position = [467 160 40 22];
 app.EditField_2.Value = 1;
 % Create Button_2
 app.Button_2 = uibutton(app.InputParametersUIFigure, 'push');
 app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @Button_2Pushed, true);
 app.Button_2.BackgroundColor = [0.949 0.9176 0.7804];
 app.Button_2.FontName = 'Comic Sans MS';
 app.Button_2.FontSize = 14;
 app.Button_2.FontColor = [0 0.451 0.7412];
 app.Button_2.Position = [19 19 157 50];
 app.Button_2.Text = 'Выбрать изображение';
 % Create Label_3
 app.Label_3 = uilabel(app.InputParametersUIFigure);
48
 app.Label_3.HorizontalAlignment = 'center';
 app.Label_3.FontName = 'Comic Sans MS';
 app.Label_3.FontColor = [0.4941 0.698 0.902];
 app.Label_3.Position = [27 259 471 22];
 app.Label_3.Text = 'Выберите изображение';
 % Create Button_3
 app.Button_3 = uibutton(app.InputParametersUIFigure, 'push');
 app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @Button_3Pushed, true);
 app.Button_3.BackgroundColor = [0.949 0.9176 0.7804];
 app.Button_3.FontName = 'Comic Sans MS';
 app.Button_3.FontSize = 14;
 app.Button_3.FontColor = [0 0.451 0.7412];
 app.Button_3.Position = [349 19 158 50];
 app.Button_3.Text = 'Сохранить';
 % Create Label_4
 app.Label_4 = uilabel(app.InputParametersUIFigure);
 app.Label_4.FontName = 'Comic Sans MS';
 app.Label_4.FontSize = 14;
 app.Label_4.FontColor = [0 0.451 0.7412];
 app.Label_4.Position = [19 126 341 22];
 app.Label_4.Text = 'Подавление шумов и немаксимумов (от 0 до 10)';
 % Create EditField_3
 app.EditField_3 = uieditfield(app.InputParametersUIFigure, 'numeric');
 app.EditField_3.Limits = [0 10];
 app.EditField_3.FontName = 'Comic Sans MS';
 app.EditField_3.Position = [467 126 40 22];
 app.EditField_3.Value = 1;
 % Create Label_5
 app.Label_5 = uilabel(app.InputParametersUIFigure);
 app.Label_5.FontName = 'Comic Sans MS';
 app.Label_5.FontSize = 14;
 app.Label_5.FontColor = [0 0.451 0.7412];
 app.Label_5.Position = [19 92 195 22];
 app.Label_5.Text = 'Толщина границ (от 0 до 5)';
 % Create EditField_4
 app.EditField_4 = uieditfield(app.InputParametersUIFigure, 'numeric');
 app.EditField_4.Limits = [0 5];
 app.EditField_4.RoundFractionalValues = 'on';
 app.EditField_4.ValueDisplayFormat = '%.0f';
 app.EditField_4.FontName = 'Comic Sans MS';
 app.EditField_4.Position = [467 92 40 22];
 app.EditField_4.Value = 1;
 % Create Label_6
 app.Label_6 = uilabel(app.InputParametersUIFigure);
 app.Label_6.FontName = 'Comic Sans MS';
 app.Label_6.FontSize = 14;
49
 app.Label_6.FontColor = [0 0.451 0.7412];
 app.Label_6.Position = [19 228 75 22];
 app.Label_6.Text = 'Оператор:';
 % Create DropDown
 app.DropDown = uidropdown(app.InputParametersUIFigure);
 app.DropDown.Items = {'Собеля', 'Робертса', 'Превитта', 'Шарра', 'Кирша'};
 app.DropDown.FontSize = 14;
 app.DropDown.FontColor = [0 0.451 0.7412];
 app.DropDown.BackgroundColor = [1 1 1];
 app.DropDown.Position = [407 228 100 22];
 app.DropDown.Value = 'Собеля';
 end
 end
 methods (Access = public)
 % Construct app
 function app = app1
 % Create and configure components
 createComponents(app)
 % Register the app with App Designer
 registerApp(app, app.InputParametersUIFigure)
 if nargout == 0
 clear app
 end
 end
 % Code that executes before app deletion
 function delete(app)
 % Delete UIFigure when app is deleted
 delete(app.InputParametersUIFigure)
 end
 end
end
