const empty = 'Поле не должно быть пустым.';

String notNumber(String text) => '$text не является числом.';
String notInteger(String text) => '$text не является целым числом.';
String lessThan(String minimum) => 'Меньше $minimum.';
String greaterThan(String maximum) => 'Больше $maximum.';

String notTime(String text) => '$text не является корректным временем.';

const timeGreaterThanEnd = 'Время больше конечного.';
const timeLessThanBegin = 'Время меньше начального.';

const invalidVehicleNumber = 'Неверный формат. Примеры: с065мк78, в777мс177';
const invalidTrailerNumber = 'Неверный формат. Примеры: ан733147, вм7771777';
