#Python-based system for webscraping for stock picks

#Import libraries
import requests
from bs4 import BeautifulSoup as bs
import time
from playsound import playsound as ps
import sys
import csv

#Variable declarations
stocksToWatch = [] 
stockWachlistFile = "stockWatchList.csv"
refreshRate = 5 #Delay to refresh the data (in seconds)


#Function declarations
#Gets data from a webpage about the stock URL passed to it
#Returns the close and open values
#COMPLETE
def getStockInfo(URL):
    
    opens = []
    closes = []
    
    #Pulls data from the URL sent to the function
    page = requests.get(URL).text
    soup = bs(page, 'html.parser')
    
    #Gets the values of opens and closes
    for i in range(0,14):
        test = soup.find_all("td", {"class":"Py(10px) Pstart(10px)"})[0+6*i].getText()
        opens.append(test)
        test = soup.find_all("td", {"class":"Py(10px) Pstart(10px)"})[4+6*i].getText()
        closes.append(test)
        
    
    return opens, closes
    
    

#Calculates the RSI based on a 14 day period and returns the value
#COMPLETE

def calculateRSI(opens, closes):
    
    gainers = []
    losers = []
    
    #For 14 iterations, calculate RSI
    #Seperates gains and losses
    for i in range(0, 13):
        
        dailyGainLoss = closes[i] - opens[i]
        gainLossPercent = closes[i]/opens[i]
        
        if(dailyGainLoss > 0):
            gainers.append(gainLossPercent)
        else:
            losers.append(gainLossPercent)
            

    #Computes the RSI
    averageGain = sum(gainers)/14
    averageLoss = sum(losers)/14
    
    tempValue = averageGain/averageLoss
    tempValue = 1 + tempValue
    tempValue = 100/tempValue
    
    RSI = 100 - tempValue
    
    return RSI


#Uses a bubble-sort approach to determine lowest RSI
#COMPLETE
def bestRSI(values):
    
    best = values[0]
    bestNum = 0
    
    for i in range(0,len(values)):
        
        if(best > values[i]):
            best = values[i]
            bestNum = i
            
    return bestNum
    
    
def main():
    
    #Gets stock watchlist from CSV file
    with open('stockWatchList.csv') as csvFile:
        csvReader = csv.reader(csvFile, delimiter=',')
        numberStocks = 0
        for row in csvReader:
            
            #Removes list attribute from data
            row = row[0]
            #Accounts for beginning of file characters
            if(numberStocks == 0):
                row = row[3:]
            
            numberStocks = numberStocks + 1
            stocksToWatch.append(row)
    
    RSIValues = ['']*numberStocks
    
    while(1):
    
        try:
            listIterator = 0
            for i in stocksToWatch:
                
                #Sends the stocks to watch to be processed through yahoo finance
                allOpens, allCloses = getStockInfo("https://finance.yahoo.com/quote/" + i + "/history?p=" + i)
                
                #Converts the opens and closes to floats
                for j in range(0,len(allOpens)):
                    allOpens[j] = float(allOpens[j])
                    
                for j in range(0,len(allCloses)):
                    allCloses[j] = float(allCloses[j])
                
                #Gets RSI for the current stock
                currentRSI = calculateRSI(allOpens, allCloses)
                print(i + " RSI: " + str(currentRSI)[:5])
                RSIValues[listIterator] = currentRSI
                listIterator = listIterator + 1
            
            lowestRSI = bestRSI(RSIValues)
            print("The lowest RSI is: " + str(RSIValues[lowestRSI])[:5] + " with the ticker: " + stocksToWatch[lowestRSI])
            #Delays to avoid overload    
            time.sleep(refreshRate)
        
        except(KeyboardInterrupt):
            print("RSI calculator has stopped")
            break
        except:
            print("An error has occured: " + str(sys.exc_info()[0]))
            break
if(__name__ == "__main__"):
    main()