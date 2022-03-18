import matplotlib.pyplot as plt
import os
import json


def gen_exec_time():
    f = open("data/exec_time.json", "r")
    json_data = json.loads(f.read())

    plt.style.use('_mpl-gallery')
    fig, ax = plt.subplots()
    figure = plt.gcf()
    figure.set_size_inches(6, 4)

    ax.barh(" ", "0s",
            height=0, edgecolor="black", linewidth=1)

    items = {}

    for i in json_data["results"]:
        items[i["command"].split(" ")[1]] = float(i["mean"])

    items = dict(sorted(items.items(), key=lambda item: item[1]))

    colors = ["orange", "blue", "cyan", "yellow",
              "magenta", "red", "green", "gray"]
    for key, val in items.items():
        ax.barh(key, "{}s".format("%.2f" % val),
                height=0.4, edgecolor="black", linewidth=1)

    ax.autoscale_view()

    plt.title("Sorting $10^{}$ elements".format(6))
    plt.xlabel("less is better")

    plt.savefig(os.path.join("image", "exec_time.png"),
                dpi=128, bbox_inches="tight")


gen_exec_time()
