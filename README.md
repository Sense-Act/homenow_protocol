# HomeNow

## Table of Contents

- [HomeNow](#homenow)
  - [Table of Contents](#table-of-contents)
  - [Protocol](#protocol)
    - [General Overview](#general-overview)
    - [Message Tasks](#message-tasks)
      - [Pair](#pair)
  - [Examples](#examples)
  - [Sources](#sources)

## Protocol

<!-- The content passed by `esp_now.h` ([source](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_now.html#_CPPv412esp_now_sendPK7uint8_tPK7uint8_t6size_t)) can be a **maximum of 250 bytes**. The body as described in `esp_now.h` can be any kind of data. However in this case it is well defined. The **Bytes index** are 0 indexed. -->

### General Overview

250 Bytes are used.

| **Bytes Index** | **Bytes Count** | **Offset** | **Name**     | **Description**                                                                                                                   |
| --------------- | --------------- | ---------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| 0 - 1           | 2               | 0          | Version      | This describes the Version of the Protocol                                                                                        |
| 2               | 1               | 2          | Message Task | Describes the task to be performed by the device. A comprehensive list of the possible tasks may be found [here](#message-tasks). |
| 3 - 249         | 247             | 1          | Content      | This is content of the message and is dependent on the message task.                                                              |

### Message Tasks

Message tasks change the structure ad the behavior of the content. The following table describes the possible tasks and their hexadecimal representation. Addtionlly for each task a table is provided that describes the structure of the content.

| **Task**      | **Description**                   | **Hexadecimal Representation** |
| ------------- | --------------------------------- | ------------------------------ |
| Get           |                                   | 0x00                           |
| Set           |                                   | 0x01                           |
| Update        |                                   | 0x02                           |
| [Pair](#pair) | Sends a pair request to a gateway | 0x03                           |

#### Pair

247 Bytes are used.

| **Bytes Index** | **Bytes Count** | **Offset** | **Name**    | **Description**                                                                                                                                               |
| --------------- | --------------- | ---------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0               | 1               | 0          | Subtask     | Describes the step in which the pairing progress currently is.                                                                                                |
| 1 - 246         | 246             | 1          | Device Type | Describes the device type of the object which sends the pairing request. Examples may be found [here](https://developers.home-assistant.io/docs/core/entity/) |


<!-- ## Examples -->

<!-- Run example by running `make run_hello_world`. -->

## Sources

- ESP-Now docs: <https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_now.html>
- Entities: <https://developers.home-assistant.io/docs/core/entity/>
