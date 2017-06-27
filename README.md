# CarND-Controls-MPC
This is my submission for the Model Predictive Controller project in term 2 of the Udacity Self-Driving Car Engineer Nanodegree Program. For details of the project, refer to the source [repo](https://github.com/udacity/CarND-MPC-Project).

---

## Instructions for Ubuntu
* [uWebSockets](https://github.com/uWebSockets/uWebSockets)
    ```
    git clone https://github.com/uWebSockets/uWebSockets 
    ```
* [Ipopt](https://www.coin-or.org/download/source/Ipopt/)
    ```
    https://www.coin-or.org/download/source/Ipopt/Ipopt-3.12.7.zip
    unzip Ipopt-3.12.7.zip
    ./install_ipopt.sh Ipopt-3.12.7
    rm Ipopt-3.12.7.zip
    ```
* Build Docker Image
    ```
    docker build -t <imagename>:<imagetag> .
    ```
* Run image (Port 4567 is used to talk with the simulator).
    ```
    docker run -it -p 4567:4567 -v <path to your project code>:/src/udacityterm2 <imagename>:<imagetag> bash
    ```
    
## Dependencies and other Build Instructions

Please see original [repo](https://github.com/udacity/CarND-MPC-Project)

# Implementation

## Model

The general setup for MPC is described as:
1. Define the length of the trajectory, N, and duration of each timestep, dt.
2. Define vehicle dynamics and actuator limitations along with other constraints.
3. Define the cost function.

The MPC model is essentially the same as that presented in class. In each time-step, the vehicle state vector consists of the coordinates (x,y), the yaw angle (psi), the cross track error (cte), and the orientation error (epsi). The actuators are simply input steering angle and throttle, which are the two control parameters passed to the Unity simulator. The objective cost function tries to optimize two objectives - 1) speed (close to desired speed), and  2) follows trajectory (close to polynomial line). 

The suggested weights for each of the cost function components ou adopted without further tuning since they worked out of the box (`MPC.cpp` lines 55-71):
* ref_cte: 2000
* ref_epsi: 2000
* ref_v: 1
* delta (steer_angle): 5
* acceleration (throttle): 5
* smoothness of delta: 200
* smoothness of throttle application: 10

Code details:
* The cost function is defined in `MPC.cpp` lines 54-71,
* The contraints are defined in `MPC.cpp` lines 82-131,
* The lower and upper bounds for the actuators are in `MPC.cpp` lines 175-190,
* The update equations are in `MPC.cpp` lines 124-131,
* The heavy lifting of optimization and fitting is done by the Ipopt library, called inside `MPC::Solve()`. The inputs to this function are assembled in `main.cpp` lines 99-140, based on updates returned from the simulator. 

## Timestep Length and Elapsed Duration

The timestep length N is chosen as 10 (`MPC.cpp` line 9), while the elapsed duration between timesteps dt is chosen as 0.1. These parameters are default values suggested by Udacity and provides a good balance between a reasonable observation horizon and CPU processing load. Since these values work very well on first try, I did not try other values.

## Polynomial Fitting and MPC Preprocessing

A 3rd degree polynomial is fitted to the provided waypoints. The 3rd degree is need to handle more windy portions of the track and higher degree may lead to overfitting. 

Before proceeding with the updates, the waypoints which were in global coordinates, are first transformed to the vehicle's coordinate system. This is done by first translation by the car's location (`main.cpp` lines 101-102) and then rotation by the yaw angle (`main.cpp` lines 103-104). Further preprocessing for latency considerations are described in the section below. 

## Model Predictive Control with Latency 

The Model Predictive Control is also implemented to handle a 100 millisecond latency (`main.cpp` line 206), i.e. the car only react to the actuators after 100ms. To handle this delay, a predicted state is first calculated 100ms into the future, using the same update equations in the MPC (`main.cpp` lines 127-133). The new predicted state is feed to the solver, instead of the real observed state. In this way, the returned solution correspond to a future state that is 100ms ahead.

## Obsevations

Without latency, the default MPC solution was able to control the car smoothly around the track. When I added the artificial latency, but do nothing to the MPC algorithm, the car swerves significantly, especially around bendy sections of the track. This shows the impact of actuator latency and is mitigated by using an estimated future state instead of the current observed state for processing. This is not possible with the simple [PID controller](https://github.com/lowspin/CarND2-Proj04-PID-Contoller). 

## Conclusion

After observing the car in the simulator for a few lapse, I am sure the MPC can successfully control the car to navigate the planned route without problems, even with a 100ms actuation delay.
