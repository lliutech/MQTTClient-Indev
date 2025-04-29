#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <time.h>

const char* ssid = "YOUR_WIFI_NAME";       // WiFi网络名称
const char* password = "YOUR_WIFI_PASSWORD"; // WiFi网络密码

// MQTT Broker settings
const char *mqtt_broker = "YOUR_MQTT_SERVER_ADDRESS";  // EMQX broker endpoint
const char *mqtt_topic = "YOUR_TOPIC";     // MQTT topic
const char *mqtt_username = "YOUR_CONNECTION_USERNAME";  // MQTT username for authentication
const char *mqtt_password = "YOUR_CONNECTION_PASSWORD";  // MQTT password for authentication
const int mqtt_port = 8883;  // MQTT port (TCP)


// 初始化MQTT客户端
BearSSL::WiFiClientSecure espClient;
PubSubClient mqtt_client(espClient);

// 连接MQTT服务器的SSL证书
static const char ca_cert[]
PROGMEM = R"EOF(
//********************
//PASTE_YOUR_CERT_HERE
//********************
)EOF";


struct DeviceConfig {
    int ledPin;        // LED 引脚
    int outputPin;     // 控制引脚

    int mode;

    int startHour;      // 起始小时
    int startMinute;    // 起始分钟
    int endHour;     // 关闭小时
    int endMinute;   // 关闭分钟
    int duration;      // 计时器时间 默认分钟
    bool targetStatue; // 定时模式预期状态

    bool manualStatue;

    bool Statue;       // 触发
};

// 提前声明mode为模式，当为0时为计时器、为1时为手动控制
// 初始化结构
DeviceConfig config = {
    .ledPin = 2,
    .outputPin = D1,

    .mode = 0,

    .startHour = 0,
    .startMinute = 0,

    .endHour = 0,
    .endMinute = 0,
    .duration = 0,
    .targetStatue = false,
    .manualStatue = false,

    .Statue = false,
};

void connectToMQTT() {
  // 设置CA证书杂项
  BearSSL::X509List serverTrustedCA(ca_cert);
  espClient.setTrustAnchors(&serverTrustedCA);
  while (!mqtt_client.connected()) {
    // 生成连接客户端ID
    String client_id = "esp8266-client-" + String(WiFi.macAddress());
    Serial.printf("正在作为%s连接服务器.....\n", client_id.c_str());
    if (mqtt_client.connect(client_id.c_str(), mqtt_username, mqtt_password)) {
      Serial.println("已连接到服务器");
      // 订阅主题
      mqtt_client.subscribe(mqtt_topic);
    } else {
      Serial.print("连接服务器失败, rc=");
      Serial.print(mqtt_client.state());
      Serial.println(" 在5秒后尝试重连");
      delay(5000);
    }
  }
}

void mqttCallback(char *topic, byte *payload, unsigned int length) {
  Serial.print("接收消息");
  Serial.println(topic);

  char charArray[length + 1];
  memcpy(charArray, payload, length); // 复制数据到charArray
  charArray[length] = '\0'; // 添加结束标志

  DynamicJsonDocument doc(1024); // 创建一个动态 JSON 文档
  DeserializationError error = deserializeJson(doc, String(charArray));

  serializeJsonPretty(doc, Serial); // 使用 Pretty 格式打印
  Serial.println();

  if (error) {
      Serial.print("JSON 解析失败: ");
      Serial.println(error.c_str());
      if (String(charArray) == "query") {
        mqtt_client.publish(topic, "");
      }
  } else {
    // 提取数据并更新配置
    config.mode = doc["mode"];

    config.startHour = doc["openHour"];
    config.startMinute = doc["openMinute"];
    config.endHour = doc["closeHour"];
    config.endMinute = doc["closeMinute"];
    config.duration = doc["duration"];
    config.targetStatue = doc["targetStatue"];
    config.manualStatue = doc["manualStatue"];
  }
}

void setupTime() {
  // 时区偏移 中国：UTC+8
  configTime(8*3600, 0, "ntp.aliyun.com");
}

void connect_wifi(){ // 连接WIF
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.print("已连接到：");
  Serial.println(ssid);
  Serial.print("IP地址为：");
  Serial.println(WiFi.localIP());
  
  delay(100);
}

void returnNowTime(int& hour, int& minute) { //通过参数引用直接为时间变量赋值
    time_t now = time(nullptr);
    struct tm* timeinfo = localtime(&now);
    hour = timeinfo->tm_hour;
    minute = timeinfo->tm_min;
}

void ProgramBuilder(unsigned long& Timer, int currentHour, int currentMinute){
  // 根据模式来切换任务
  switch (config.mode){

    // 如果是默认值，不进行任何操作
    case 0:
      break;

    // 如果是定时器控制
    case 1:
      // 如果预期的状态是关，则先开后关
      if (currentHour == config.startHour && currentMinute == config.startMinute) {
        if (config.duration < 0) {
          config.Statue = config.targetStatue;
        }
        Timer = millis();
      }
      MonitorTimer(Timer, config.targetStatue);
      break;

    // 如果是手动监测
    case 2:
      config.Statue = config.manualStatue;
      break;
  }

  // 开关监测
  digitalWrite(config.outputPin, config.Statue ? HIGH : LOW);
}

void MonitorTimer(unsigned long& Timer, bool target) {
    // 计时监测 输入为Timer计时器 和 到期时状态

    if (millis() - Timer >= config.duration * 60 * 1000) {
      config.Statue = !target;
    } else {
      config.Statue = target;
    }
}

void setup() {
  Serial.begin(115200); // 初始化串口波特率
  pinMode(config.outputPin, OUTPUT);  // 将设备控制引脚设置为输出模式
  pinMode(config.ledPin, OUTPUT);
  connect_wifi(); // 连接WIFI
  setupTime(); // 设置时间
  mqtt_client.setServer(mqtt_broker, mqtt_port); // 设置服务器地址及端口
  mqtt_client.setCallback(mqttCallback); // 设置回调函数
  connectToMQTT();  // 连接服务器
}

void loop() {
  // 先声明变量
  int currentHour, currentMinute;
  static unsigned long Timer = 0;

  if (!mqtt_client.connected()) {  // 确保链接持续
    connectToMQTT();
  }
  mqtt_client.loop();
  returnNowTime(currentHour, currentMinute); // 对时间变量进行赋值

  // 打印当前时间
  // Serial.print("当前时间: ");
  // Serial.print(currentHour);
  // Serial.print(":");
  // Serial.println(currentMinute);
  ProgramBuilder(Timer, currentHour, currentMinute);

  delay(200);  // 添加延时 避免过快刷新
}
