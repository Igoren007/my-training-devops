Initializing the Replica Set:

Generate authentication key file bash setup.sh
Start the containers: docker-compose up -d
Bash into one container: docker exec -it mongo1 bash
Run mongosh -u root -p example
Initiate the replica set using:
 rs.initiate(
  {
    _id: "rs0",
    version: 1,
    members: [
      { _id: 0, host: "mongo1:27017" },
      { _id: 1, host: "mongo2:27018" },
      { _id: 2, host: "mongo3:27019" }
    ]
  }
)
you can confirm replica status using rs.status()