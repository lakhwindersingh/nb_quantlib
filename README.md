# nb_quantlib
Quantlib container with Jupyter and Python bindings for rapid prototying.

1. Docker compose expects location at line 15 in docker-compose.yml, currently pointing towards </data/code/projects/notebook>, which will be mapped to /home/jupyter/notebook. Replace this prior to running following commands.

2. Run  command to build the quantlib from the source with python bindings.

        docker-compose build

3. Run  command to bring up quantlib on local port 8282

        docker-compose up
        
4. Point your browser to https://0.0.0.0:8282 or https://127.0.0.1:8282 to run quantlib python samples        


                                                            Courtesy - Infectolabs@ Neutron Binary LLC
        


