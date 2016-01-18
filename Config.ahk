;;
;; Config for AdminHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;; Version: 1.0b5 (Jul 19, 2015)
;;


AdminLVL = 5                                     ; LVL Администратора (все функции, не соответствующие lvl'у, отключатся автоматически)


;;   1 lvl

; Ответ на последнее SMS
; (в строку ввода сообщения будет вставлено: "/t [id_игрока_в_последнем_смс] ")

LastSMSKey = !vk54                               ; Клавиша (по-умолчанию, Alt+T)

LastSMSOnlyReceivedBoolean = 0                   ; 1 - Учитывать только полученные сообщения (без отправленных)
				                                         ; 0 - Учитывать и полученные, и отправленные сообщения


; Ответ на последний репорт
; (в строку ввода сообщения будет вставлено: "/pm [id_игрока_в_последнем_репорте] ")

LastPMKey = !vk50                                ; Клавиша (по-умолчанию, Alt+P)

LastPMOnlyReceivedBoolean = 0                    ; 1 - Учитывать только полученные репорты (без ответов)
				                                         ; 0 - учитывать и полученные репорты, и отправленные ответы


; Ответ последнему игроку, которому вы выдали бан чата или посадили в ДеМорган
; (в строку ввода сообщения будет вставлено: "pm [id_последнего_наказанного_игрока] ")

PMToLastMuteOrDMKey = !vk55                      ; Клавиша (по-умолчанию, Alt+U)


;;   2 lvl

; TagName (WH)

TagNameAutostartBoolean = 1                      ; 1 - Автоматически запускать TagName при старте скрипта
                                                 ; 0 - Не запускать автоматически (запускать только после ввода `/wh` в игре)


; AutoHP

AutoHPMinHP = 95                                 ; Количество HP, при котором будет срабатывать скрипт (по-умолчанию, 95)

AutoHPTimeout = 10                               ; Промежутки в секундах между автоматической проверкой HP (по-умолчанию, 10)

AutoHPAutostartBoolean = 1                       ; 1 - Автоматически запускать AutoHP при старте скрипта
                                                 ; 0 - Не запускать автоматически (запускать только после ввода `/autohp` (`/ahp`) в игре)

AutoHPMessageBoolean = 1                         ; 1 - Выводить сообщение, уведомляющее о каждом автоматическом пополнении HP
                                                 ; 0 - Не выводить сообщение


; Recon

;; Подключиться к ID, указанному в тексте последнего репорта
;; (анализируются только репорты с числами в тексте)

ReconLastPMKey = Numpad2                         ; Клавиша (по-умолчанию, NumPad2)

;; Подключиться к ID в последнем Warning'е

ReconLastWarningKey = Numpad3                    ; Клавиша (по-умолчанию, NumPad3)


; Recon Viewer

ReconViewerMaxLVL = 3                            ; Максимальный LVL игроков для просмотра через Recon Viewer (по-умолчанию, 3)

ReconViewerTimeout = 5                           ; Пауза в секундах между автоматическим цикличный просмотром игроков через Recon (по-умолчанию, 5)

ReconViewerNextKey = !vkBE                       ; Клавиша переключения на следующего по ID игрока (по-умолчанию, Alt+Ю)

ReconViewerPrevKey = !vkBC                       ; Клавиша переключения на предыдущего по ID игрока (по-умолчанию, Alt+Б)

;; Запустить автоматический цикличный просмотр игроков через Recon

ReconViewerStartKey = !vk4C                      ; Клавиша запуска цикла (по-умолчанию, Alt+L)

ReconViewerStopKey = !vk4B                       ; Клавиша остановки цикла (по-умолчанию, Alt+K)


; Ignore List

IgnoreList := ["Flazy_Fad", "Donny_Hayes", "Yann_Dobermann", "El_Capone", "Solomon_Adamov", "Vito_Anjello", "Emilio_Leon", "Alex_Nilsson", "Kamil_Boyka", "Vyacheslav_Ivankov", "Valik_Derevyanko", "Aleksey_Nechaev", "Alex_Merphy", "Aleksandro_Balotelli", "Vitaliy_Leonov", "Anton_Xabibullin", "John_Toronto", "Gabriele_Soto", "Richard_Alpert", "Theodore_Long", "Maga_Bagamaev", "Aidar_Valeyev", "Alessandro_Armani", "Maks_Kruger", "Alex_Deniro", "Lexa_Diablo", "Davi_Soto", "Nikita_Gryadunov", "Emmett_Hartley", "Mario_Brossi", "Filipp_Savchuk", "Serega_Sed", "Butter_Fly", "Benjamin_Stone", "Alek_Lester", "Diego_Revolt", "Zhenya_Bocharov", "Set_Willson", "Vladimir_Bondarenko", "Evgen_Kozlov", "Zhan_Dicaprio", "Sergio_Esteban", "Lee_Brooks", "Max_Hall", "Maks_River", "Maks_Sergeev", "Brian_Davis", "Marco_Barrosi", "Anton_Shkvarov", "Yoda_Sensei", "Mark_Vavillov", "Antonio_Mariarti", "Ruslan_Vlasov", "Doc_Elition", "Thomas_Versetti", "Tommy_Barbaro", "Roma_Mexanik", "Vovich_Robin", "Leonid_Litvinenko", "Erick_Miller", "Dima_Horow", "Kurt_Rock", "Igor_Doyal", "Phil_Galfond", "Christopher_Benitez", "Fill_Russel", "Roman_Hennesy", "Fedor_Manyc", "Johny_Fletcher", "Pavel_Snow", "Danya_Fox", "Christopher_Bell", "Alan_Hill", "Richard_Gun", "Vlados_Step", "Dave_Parker", "Mark_Laev", "Igor_Green", "Calvin_Anthony", "Aleks_Katsuba", "Antonio_Barbaro", "Alexey_Mikenin", "Frank_Zuzuka", "Ben_Grous", "Riccardo_Jerome", "Evgenie_Gluhov", "Alexandr_Sab", "Vadim_Gromov", "Yuriy_Baranov", "Jeffrey_Bradberry", "Aiden_Gastly", "Yurij_Taran", "Danil_Valov", "Enrique_Houston", "Diego_Aminatore", "Vladislav_Rudenko", "John_Markoff", "Frank_Lampard", "Viktor_Monetti", "Viktor_Myrazor", "Larvell_Jones", "Timon_Soto", "Maks_Collins", "Dmitry_Set", "Danny_Villa", "Mike_Rockstar", "Denis_Ochida", "El_Blok", "Dmitry_Norton", "Francesco_Valetti", "Groin_Axe", "Mike_Lowrens", "Kai_Wallker", "Link_Tao", "Fernando_Richardson", "Jason_Miller", "Leha_Vafiev", "Chan_Lee", "Arthur_Simpson", "Tony_Tweaker", "Adrien_Brody", "Javier_Villa", "Tobey_Marshall", "Shane_Nollan", "Jordan_West", "Terry_Jones", "Drake_Wallace", "Alex_Benelli", "Dany_Morgan", "Karlo_Bruno", "Denis_Volochay", "Max_Quiet", "Alfred_Lundberg", "Paul_Walker", "Apple_Purix", "Nik_Mariarti", "Tony_Malton", "Archie_White", "Melvin_River", "Zadrot_Info", "Santa_Claus"] ; Список пользователей, которых будут пропускать в списке телепортации, списке изъятия оружия и т.п.


;;   3 lvl

; BanIP

BanIPKey = !Numpad9                              ; Клавиша бана по IP последнего забаненного игрока (по-умолчанию, Alt+NumPad9)

BanIPGetIPUsersBoolean = 1                       ; 1 - Получать список пользователей онлайн с этим же IP после нажатия кнопки бана по IP
                                                 ; 0 - Не получать список пользователей онлайн


;;   4 lvl

GetIPKey = +!vk49                                ; Клавиша получения местоположения по IP в чате (по-умолчанию, Shift+Alt+I)

GetIPToAdminChatBoolean = 1                      ; 1 - Отправлять данные о местоположении игрока в АдминЧат
                                                 ; 0 - Не отправлять данные о местоположении игрока в АдминЧат

GetIPSetNikKey = +!vk6F                          ; Клавиша получения местоположения игрока, отправившего запрос на смену ника (по-умолчанию, Shift+Alt+Numpad "/")

;;   5 lvl

; Uninvites

UninvitesListFile = UninvitesList.ini                ; Файл со списком игроков для увольнения в Offline командой `/listuninvites`


;Hbj

HbjListFile = HbjectsList.ini                        ; Файл со списком объектов, надеваемых на игроков командой `/hbj [id] [название_объекта]`