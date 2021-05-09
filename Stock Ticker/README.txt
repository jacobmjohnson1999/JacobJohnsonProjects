	This application is intended to be used as a real-time monitor of a set list of stocks. 
The functioning idea is that all data is scraped from a webpage and displayed in a user-friendly format. The sheet structure is simple to follow.
Stocks:
	This sheet is used to monitor stocks. The ticker symbol is in column 1, the price in column 2 and the daily increase (price and percentage) are column 3 and 4 respectivly. To add a new stock to the list, add the ticker symbol to the bottom of column 1. A filter is built in to allow for easy viewing (typically alphabetical) and is done manually.
Cryptocurrency:
	This sheet is used to monitor cryptocurrencies. The full name of the cryptocurrency is in column 1, the price in column 2 and the daily percent increase in column 3. No price increase is displayed. This is due ot the nature of cryptocurrency not usually being bought in full coins. To add a new cryptocurrency, add the full name to the bottom of column 1.
Stats:
	This sheet is used to determine the "biggest winner and biggest loser" stocks of the day. More information may be available in the future, based upon need.
Formulas:
	This sheet is used to for all complex formulas for all sheets. This sheet is not for modification of viewing and is used by developers to allow for easier calculation of values.

	Google sheets does not allow for automatic refresh of the formula =importxml. This means the values need to be refreshed another way. To allow for autonomy, a javascript "script" is used. This refreshes the code every 5 minutes (can be variable) based upon a time-based trigger. The script iterates through the ticker symbols (stocks) and names (cryptocurrency), deleting and replacing the name. This forces the refresh of the formula. This can also be done using the refresh symbol on the "Stocks" and "Cryptocurrency" for an immediate refresh. When refreshed, a message will appear, notifying the user that the stocks have been refreshed.
