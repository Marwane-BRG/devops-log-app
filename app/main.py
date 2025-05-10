import random
import time
from datetime import datetime
from faker import Faker
from pymongo import MongoClient

print("!!!!!! demarrage du script Python log-generator !!!!!!")

fake = Faker()

"""client = MongoClient("mongodb://mongo:27017/")"""
client = MongoClient(os.environ.get("MONGO_HOST"), 27017)
db = client["logdb"]
collection = db["logs"]

levels = ["INFO", "DEBUG", "WARNING", "ERROR", "CRITICAL"]

def generate_log():
    log = {
        "time": datetime.utcnow().isoformat(),
        "level": random.choice(levels),
        "user": fake.user_name(),
        "action": fake.sentence(nb_words=6),
        "ip": fake.ipv4()
    }
    return log

while True:
    log = generate_log()
    collection.insert_one(log)
    print(f"Log enregistré : {log}")
    time.sleep(3)
