const title = 'Проблемы заказа';

const noProblems = 'Проблемы не обнаружены';

const breakageTitle = 'Сломался';
const inactivityTitle = 'Нет связи';
const delayTitle = 'Задержка этапа';
const stoppageTitle = 'Простаивает';
const unknownProblemTitle = 'Неизвестная проблема';

String breakageSubtitle(String date, String time) => 'Водитель сменил статус на \"Сломался\" $date в $time';
String inactivitySubtitle(String date) => 'Нет связи с $date';
String delaySubtitle(String stage, String timeInterval) => 'Обнаружена задержка на этапе \"$stage\": $timeInterval';
String stoppageSubtitle(String timeInterval) => 'Автомобиль простаивает $timeInterval';
