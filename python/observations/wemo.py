import datetime
import random
import json
import uuid

from extrapolate import Scale


def createWemoObservations(dt, end, step, dataDir):

    with open(dataDir + 'sensor.json') as data_file:
        data = json.load(data_file)

    sensors = []

    for sensor in data:
        if sensor['type_']['id'] == "WeMo":
            sensors.append(sensor)
    num = len(sensors)

    fpObj = open('data/wemoData.json', 'w')

    while dt < end:

        for i in range(num / 3):
            pickedSensor = sensors[random.randint(0, num - 1)]
            id = str(uuid.uuid4())

            obs = {
                "id": id,
                "timeStamp": dt.strftime('%Y-%m-%d %H:%M:%S'),
                "sensor": pickedSensor,
                "payload": {
                    "currentMilliWatts": random.randint(1, 100),
                    "onTodaySeconds": random.randint(1, 3600)
                }
            }
            fpObj.write(json.dumps(obs) + '\n')

        dt += step

    fpObj.close()


def createIntelligentWemoObs(origDays, extendDays, origSpeed, extendSpeed, origSensor, extendSensor, speedScaleNoise,
                               timeScaleNoise, deviceScaleNoise, dataDir):

    with open(dataDir + 'observation.json') as data_file:
        observations = json.load(data_file)

    seedFile = open("data/seedWemo.json", "w")
    for observation in observations:
        if observation['sensor']['type_']['id'] == "WeMo":
            seedFile.write(json.dumps(observation) + '\n')
    seedFile.close()

    seedFile = "data/seedWemo.json"
    outputFile = "data/wemoData.json"
    scale = Scale(dataDir, seedFile, outputFile, origDays, extendDays, origSpeed, extendSpeed,
                  origSensor, extendSensor, ["currentMilliWatts", "onTodaySeconds"], speedScaleNoise, timeScaleNoise,
                  deviceScaleNoise, int)

    scale.speedScale()
    scale.deviceScale()
    scale.timeScale()