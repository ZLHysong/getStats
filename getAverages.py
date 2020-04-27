import sys
import os
from shutil import copyfile
from time import gmtime, strftime
def main():

    ramTotal = 0.00
    ramAverage = 0.00
    ramValues = 0

    cpuTotal = 0.00
    cpuAverage = 0.00
    cpuValues = 0

    hddTotal = 0.00
    hddAverage = 0.00
    hddValues = 0

    try:
        filepath = sys.argv[1]
    except:
        print("File not specified. Exiting...")
        sys.exit()

    if not os.path.isfile(filepath):
        print("File path {} does not exist. Exiting...".format(filepath))
        sys.exit()

    with open(filepath) as fp:
        for line in fp:
            # Next up, split line into an array
            # Then use the last 3 values for RAM, HDD, and CPU
            words = line.split()
            
            print(words[0] + " " + words[1]) # RAM
            print("RAM: " + format(float(words[2]), '2.0f') + "%" +
             " (" + format(float(words[3]), '2.0f') + "M" +
             " / " + format(float(words[4]), '2.0f') + "M)" +
             " | HDD: " + format(float(words[5]) * 100, '2.0f') + "%" +
             " | CPU: " + words[6]) # RAM
            print("") # CPU
            
            ramTotal = ramTotal + float(words[2])
            ramValues = ramValues + 1

            hddTotal = hddTotal + float(words[5])
            hddValues = hddValues + 1

            cpuTotal = cpuTotal + float(words[6])
            cpuValues = cpuValues + 1
    
    ramAverage = ramTotal / ramValues
    hddAverage = hddTotal / hddValues
    cpuAverage = cpuTotal / cpuValues
    print("RAM Average: " + format(ramAverage, '2.0f') + "%") # RAM
    print("HDD Average: " + format(hddAverage * 100, '2.0f') + "%") # RAM
    print("CPU Average: " + format(cpuAverage, '.2f') + "") # RAM

    f = open("avglog.txt", "a")
    f.write("RAM Average: " + format(ramAverage, '2.0f') + "% ") # RAM
    f.write("HDD Average: " + format(hddAverage * 100, '2.0f') + "% ") # RAM
    f.write("CPU Average: " + format(cpuAverage, '.2f') + "\n") # RAM
    f.close()

    today = strftime("%Y%m%d", gmtime())
    
    if os.path.exists("log" + today + ".txt"):
        print("file exists")
    else:
        copyfile("log.txt", "log" + today + ".txt")
        open("log.txt", "w").close()

if __name__ == '__main__':
    if os.stat("log.txt").st_size > 0:
        main()
    else:
        print("Log file is empty.")