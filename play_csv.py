from argparse import ArgumentParser
import pandas as pd
import threading
import datetime
from pythonosc.udp_client import SimpleUDPClient

COLLIDER_IP = '127.0.0.1'
COLLIDER_PORT = 57120
COLLIDER_ROUTE = '/interpreter_input'
collider_client = SimpleUDPClient(COLLIDER_IP, COLLIDER_PORT)


def send_data(index, time):
    row = df.iloc[index]
    text = row['baromabs']
    category = row['temp']
    print("sending", text, '-', category)
    collider_client.send_message(COLLIDER_ROUTE, [text, category])
    set_timer(index + 1, time)


def set_timer(index, prev_time):
    if index < len(df):
        row = df.iloc[index]
        time = datetime.datetime.strptime(row['time'], '%Y-%m-%dT%H:%M:%S.%fZ')
        interval = time - prev_time
        t = threading.Timer(interval.total_seconds(), send_data, args=(index, time))
        t.start()
    else:
        print("done")

def scale_time(factor):
    new_deltas = []
    times = [str(x[11:]).replace("Z","") for x in df['time']]
    deltas = pd.to_timedelta(times)
    for i, d in enumerate(deltas):
        new_deltas[i] = d.minute * factor

    print(new_deltas[10:])


if __name__ == '__main__':
    parser = ArgumentParser(
        prog='PlayCsv',
        description='plays the content of a csv as if it was a live show (send to supercollider)')
    parser.add_argument('filename')
    args = parser.parse_args()

    df = pd.read_csv(args.filename)
    scale_time(1/60)
    first_row = df.iloc[0]
    first_time = datetime.datetime.strptime(first_row['time'], '%Y-%m-%dT%H:%M:%S.%fZ')
    set_timer(0, first_time)
