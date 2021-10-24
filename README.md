# nb_quantlib
Quantlib container with Jupyter and Python bindings for rapid prototying.

Docker compose expect location at line 15 in docker-compose.yml, currently pointing towards </data/code/projects/notebook>, which will be mapped to /home/jupyter/notebook. Replace this prior to running following commands.

Run following command to build the quantlib from the source with python bindings.

        docker-compose build

Run following command to bring up quantlib on local port 8282

        docker-compose up


