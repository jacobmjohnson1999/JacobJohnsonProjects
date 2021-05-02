#Python-based MIPS compiler for ECE 4140

#Data definitions
Number_Of_Spaces = 256
Data_Length = 32
Starting_Location = 00
Output_File_Name = "Assembly.mif"
User_Code_File = "ReadCode.txt"

#Delcares standard beginning of file lines
Generic_Line_1 = "DEPTH = " + str(Number_Of_Spaces) + ";                   -- The size of memory in words"
Generic_Line_2 = "WIDTH = " + str(Data_Length) + ";                    -- The size of data in bits"
Generic_Line_3 = "ADDRESS_RADIX = HEX;          -- The radix for address values"
Generic_Line_4 = "DATA_RADIX = BIN;             -- The radix for data values"
Generic_Line_5 = "CONTENT                       -- start of (address : data pairs)"
Generic_Line_6 = "BEGIN"
Generic_Line_7 = "[00..FF]:00000000000000000000000000000000;"

openingLines = [Generic_Line_1, Generic_Line_2, Generic_Line_3, Generic_Line_4, Generic_Line_5, Generic_Line_6, "", Generic_Line_7, ""]

R_Type_Instructions = ["add", "sub", "and", "or"]
Registers = ["$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6", "$t7", "$s0", "$s1", "$s2", "$s3", "$s4", "$s5", "$s6", "$s7", "$t8", "$t9"]
I_Type_Instructions = ["sw", "beq"]
I_Type_OpCode = ["101011", "000100"]
Register_Binary = ["01000", "01001", "01010", "01011", "01100", "01101", "01110", "01111", "10000", "10001", "10010", "10011", "10100", "10101", "10110", "10111", "11000", "11001"]

#Inserts a line to the text file adding the end of line delimiter
def insertLine(myText, f):
    
    f.write(myText+"\n")
    
def storeCompiledCode(lineNumber, code, f):
    
    insertLine(hex(lineNumber)[2:] + ": " + code, f)
    
def convertCode(fileLine):
    
    #Creates empty string
    myString = ""
    R_Type = ""
    I_Type = ""
    iterator = 0
    
    #Manipulates string for parsing
    tempFileLine = fileLine.replace(",", "")
    listOfoperatiors = tempFileLine.split(" ")
    
    #Iterates through each command
    for i in listOfoperatiors:
            
        #Does logic for immediate values of I-type instructions
        try:
            i = int(i)
            i = bin(i)[2:]
            myString = myString + "0"*(16-len(i)) + i
            
        except(TypeError):
            pass
        except(ValueError):
            pass
        
        #Adds destination register in appropriate place
        if(I_Type != "" and iterator == 2):
            myString = myString + Destination_Register
            iterator = iterator + 1
            
        if(i.replace("(", " ") != i):
            tempVal = i.replace("(", " ")
            tempVal = tempVal[0:-1]
            tempValues = tempVal.split(" ")
            
            #Swaps the order of the operations
            listOfoperatiors[iterator-1] = tempValues[1]
            #listOfoperatiors[iterator] = tempValues[0]
            listOfoperatiors.append(tempValues[0])
            i = tempValues[1]

        #Tests for R-type instructions
        for j in R_Type_Instructions:
            if(i == j):
                myString = myString + "000000"
                R_Type = j
                break
        
        #Tests for I-type instructions
        counter = 0
        for j in I_Type_Instructions:
            if(i == j):
                myString = myString + I_Type_OpCode[counter]
                I_Type = i
                break
            counter = counter + 1
            
        #Checks for registers
        if(i[0] == "$"):
            counter = 0
            for j in Registers:
                if(j == i):
                    if(iterator == 1):
                        Destination_Register = Register_Binary[counter]
                        break
                    else:
                        myString = myString + Register_Binary[counter]
                        break
                counter = counter + 1
                
        iterator = iterator + 1
    
    #Does function code for R-type instructions
    if(R_Type != ""):
        myString = myString + Destination_Register
        myString = myString + "00000"
        if(R_Type == "add"):
            myString = myString + "010000"
        elif(R_Type == "sub"):
            myString = myString + "010010"
        elif(R_Type == "and"):
            myString = myString + "010100"
        elif(R_Type == "or"):
            myString = myString + "100101"
    
    
    myString = myString + "; --" + fileLine
    return myString

def main():
    #Opens file
    f = open(Output_File_Name, "w")

    #Gives credit to author
    insertLine("--Assembled using Jacob Johnsons's assembler.",f)
    
    #Writes generic opening lines
    for i in openingLines:
        insertLine(i, f)

    #Does error checking for valid file
    try:
        codeFile = open(User_Code_File, "r")
    except FileNotFoundError:
        print("ERROR: File " + User_Code_File + " does not exist. Store code you want to compile in this file with each code being on a serperate line.")
        exit()
        
    #Does logic for reading from file
    i = 0
    while True:
        currentLine = codeFile.readline()
        if(currentLine == ""):
            break
        else:
            currentLine = currentLine.rstrip("\n")
            currentLine = convertCode(currentLine)
            
            #Used for debugging
            storeCompiledCode(i, currentLine, f)
            i = i + 1
            
    codeFile.close()
    f.write("\nEND;")
    f.close()
    #Does logic for complete
    print("Compiled code is in the file " + Output_File_Name)

if __name__ == '__main__':
    main()