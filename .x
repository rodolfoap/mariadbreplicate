case "$1" in
e)	vi -p docker-compose.yaml master.cnf slave.cnf
	;;
m)	docker exec -it master bash;;
s)	docker exec -it slave  bash;;
mm)	docker exec -it master mysql -u root -ppassword;;
ss)	docker exec -it slave  mysql -u root -ppassword;;
"")	docker-compose up -d
	docker-compose logs
	./setup_master
	./setup_slave
	./setup_db
	;;
esac
