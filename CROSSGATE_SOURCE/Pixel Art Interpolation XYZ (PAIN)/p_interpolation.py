from PIL import Image
from os import listdir
from os.path import isfile, join

def interpolate(imgA, imgB): #(String imgA, String imgB)
    imgA = Image.open("png_input_sequence\\" + imgA).convert("RGBA")
    imgB = Image.open("png_input_sequence\\" + imgB).convert("RGBA")
    dataA = imgA.getdata()
    dataB = imgB.getdata()
    dataAB = []

    if len(dataA) == len(dataB):
        for p in range(len(dataA)):
            #Se um pixel não-nulo se tornou nulo...
            #if dataA[p][3] == 255 and dataB[p][3] == 0:
            #    dataAB.append((dataA[p][0], dataA[p][1], dataA[p][2], 60))
            #Se um pixel nulo se tornou não-nulo...
            #elif dataA[p][3] == 0 and dataB[p][3] == 255:
            #    dataAB.append((dataB[p][0], dataB[p][1], dataB[p][2], 60))
            #else:
            #    dataAB.append(dataA[p])

            if dataA[p][3] > 0 and dataB[p][3] == 0:
                dataAB.append((dataA[p][0], dataA[p][1], dataA[p][2], int(dataA[p][3]/4)))
            elif dataA[p][3] == 0 and dataB[p][3] > 0:
                dataAB.append((dataB[p][0], dataB[p][1], dataB[p][2], int(dataB[p][3]/4)))
            else:
                dataAB.append(dataA[p])

    interpolatedFrame = imgA
    interpolatedFrame.putdata(dataAB)

    outputFiles = len([f for f in listdir("png_output_sequence") if isfile(join("png_output_sequence", f))])

    interpolatedFrame.save("png_output_sequence\\" + str(outputFiles + 1) + ".png")
    imgB.save("png_output_sequence\\" + str(outputFiles + 2) + ".png")

files = [f for f in listdir("png_input_sequence") if isfile(join("png_input_sequence", f))]

for i in range(len(files)):
    if(i == (len(files) - 1)):
        interpolate(files[i], files[0])
    else:
        interpolate(files[i], files[i+1])

print("Interpolação concluída.")
