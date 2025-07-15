#!/usr/bin/python3

import RPi.GPIO as GPIO
import time
import config # config stuff

GPIO.setmode(GPIO.BCM)
GPIO.setup(config.egress2_pin, GPIO.OUT)
GPIO.output(config.egress2_pin, GPIO.LOW) # relay closed
time.sleep(2)
GPIO.output(config.egress2_pin, GPIO.HIGH) # relay open
GPIO.cleanup()
