int statusCodeOk = 200;
int statusCodeCreated = 201;
int statusCodeNotFound = 404;

bool isInformational(int statusCode) => statusCode >= 100 && statusCode < 200;
bool isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;
bool isRedirection(int statusCode) => statusCode >= 300 && statusCode < 400;
bool isClientError(int statusCode) => statusCode >= 400 && statusCode < 500;
bool isServerError(int statusCode) => statusCode >= 500 && statusCode < 600;
