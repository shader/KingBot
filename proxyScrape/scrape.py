import sys
from BeautifulSoup import BeautifulSoup
from ghost import Ghost
ghost = Ghost(wait_timeout=60)

from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

db = create_engine('sqlite:///proxiestest.db')
Base = declarative_base(bind=db) #Base class of all models

#Define a model class
class Proxy(Base):
	__tablename__ = 'proxies'
	id = Column(Integer, primary_key=True)
	ipAddress = Column(String)
	port = Column(String)
	protocol = Column(String)
	anonymity = Column(String)
	country = Column(String)
	region = Column(String)
	city = Column(String)
	uptime = Column(Float)
	response = Column(Float)
	transfer = Column(Float)

Base.metadata.create_all(db) # create tables 
Session = sessionmaker(bind=db)
s = Session()

while True:
	try:
		page, resources = ghost.open('http://www.freeproxylists.net/')
		soup = BeautifulSoup(ghost.content)
		pages = soup.find("div", "page").findAll('a')
	except:
		ghost.show()
		try:
			result, resources = ghost.wait_for_selector("table.DataGrid")
			soup = BeautifulSoup(ghost.content)
			pages = soup.find("div", "page").findAll('a')
			break
		except:
			continue
	break
	
lastPage = int(pages[-2].string)

for i in range(1,lastPage+1):
	print str(i) + '/' + str(lastPage) + ' - ' + str(i*100/lastPage) + '%'
	while True:
		try:
			page, resources = ghost.open('http://www.freeproxylists.net/?page=' + str(i))
			soup = BeautifulSoup(ghost.content)
			rows = soup.find("table", "DataGrid").findAll('tr')
		except:
			ghost.show()
			try:
				result, resources = ghost.wait_for_selector("table.DataGrid")
				soup = BeautifulSoup(ghost.content)
				rows = soup.find("table", "DataGrid").findAll('tr')
				break
			except:
				continue
		break
	
	for row in rows:
		if row.find('img'):
			columns = row.findAll('td')
			
			rowProxy = Proxy()
			
			rowProxy.ipAddress = str(columns[0].find('a').contents[0])
			rowProxy.port = str(columns[1].contents[0])
			rowProxy.protocol = str(columns[2].contents[0])
			rowProxy.anonymity = str(columns[3].contents[0])
			rowProxy.country = str(columns[4].contents[1][1:])
			rowProxy.region = str(columns[5].contents[0]) if columns[5].contents else ''
			rowProxy.city = str(columns[6].contents[0])if columns[6].contents else ''
			rowProxy.uptime = float('.'+ str(columns[7].contents[0][:-1]).replace('.', ''))
			rowProxy.response = float('.' + str(columns[8].find('span')['style'])[6:].split('%')[0])
			rowProxy.transfer = float('.' + str(columns[9].find('span')['style'])[6:].split('%')[0])
			
			s.add(rowProxy)
			s.commit()