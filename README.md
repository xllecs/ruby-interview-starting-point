# Backend Interview Starting Point

This repo will serve as a starting point for your code challenge. Feel free to change anything in order to complete it: Change framework, other tests, new gems etc.

## Get this repo

- Fork this repo
- Clone your fork

## Prerequisites
- Have RVM installed: https://letmegooglethat.com/?q=install+rvm+on+ubuntu

## Local setup
1. Install ruby: `$ rvm install 3.4.1`
2. `$ cd .` or `$ cd <path_to_project>` to auto-create the rvm gemset
3. Install bundler: `$ gem install bundler`
4. Install the dependencies with bundler: `$ bundle install`

## Run sample CLI command
`$ bin/ruby-interview`

## Run tests
`$ bundle exec rspec`

## Tools

- Write HTTP APIs [rails](https://rubyonrails.org/) or [roda](https://roda.jeremyevans.net/documentation.html) or others
- Write CLI tools [thor](http://whatisthor.com/) or [tty](https://ttytoolkit.org/) or others (including [rake](https://github.com/ruby/rake))
- Test your code with [rspec](https://rspec.info/)

---

Good luck!


# Problem

## Overview

You have been hired by a company that builds a app for coffee addicts. You are 
responsible for taking the user’s location and returning a list of the three closest coffee shops.

## Starting point

Fork or clone our ruby starter project: https://github.com/Agilefreaks/ruby-interview-starting-point

## Input

The coffee shop list is a comma separated file with rows of the following form:
`Name,X Coordinate,Y Coordinate`

The quality of data in this list of coffee shops may vary. Malformed entries should cause the 
program to exit appropriately. 

Notice that the data file will be read from an network location
(ex: https://raw.githubusercontent.com/Agilefreaks/test_oop/master/coffee_shops.csv)

## Output

Write a REST API in Rails that offers the posibility to take the user's coordinates and
return a list of the three closest coffee shops (including distance from the user) in 
order of closest to farthest. These distances should be rounded to four decimal places. 

Assume all coordinates lie on a plane.

## Example

Using the [coffee_shops.csv](data/coffee_shops.csv):

__Input__
```
47.6 -122.4
```

__Expected output__
```
Starbucks Seattle2,0.0645
Starbucks Seattle,0.0861
Starbucks SF,10.0793
```

# Implementation

## CLI command
I have implemented the CLI command using the Thor gem which is a neat and smooth way to set up your own custom CLI commands.
The current logic will make sure that the passed arguments are nothing else than numerical values and that they do not exceed
the valid ranges.
It leverages [CoffeeShopsService](https://github.com/xllecs/ruby-interview-starting-point/blob/develop/coffee_shops_api/app/services/coffee_shops_service.rb) in which the heavy lifting is being taken care of and it will return the 3 closest coffee shops.
In the end, the command will output the shops in the terminal in ascending order by distance.

We have got a couple options we can use:
- `--url`: Provide a URL that points to a valid CSV dataset.
- `--file`: Provide a file path to a CSV dataset.

Not using any of the options above will default to using a pre-configured local file.

## Coffee shops service
`CoffeeShopsService` is responsible for:
- Fetching the coffee shops.
- Validating them.
- Calculating the distance between the user and each coffee shop. 
- Sorting the coffee shops and returning the 3 closest ones to the user.

Depending on the options passed to the CLI command the service will use one of `get_coffee_shops_from_file` and `get_coffee_shops_from_url`.

Both of these methods make use of `parse_coffee_shops` where one of two things will happen:
- Raise an error if any of the rows is malformed.
- Create a hash based on the row's elements otherwise.

Lastly, `get_closest_coffee_shops` is where we calculate the distance and sort the results in ascending order by distance.  
Since we assume that all coordinates lie on a plane, we can make use of the Euclidian distance formula:  

$`\sqrt{(x_2-x_1)^2+(y_2-y_1)^2}`$  

where:
- $`(x_1, y_1)`$ represents the user's coordinates.
- $`(x_2, y_2)`$ represents the coffee shop's coordinates.

## How to use the API
1. `cd` into the `coffee_shops_api` folder.
2. Execute `thor coffee_shops:closest_shops 47.6 -122.4`.

Example output:
```
Starbucks Seattle2,0.0645
Starbucks Seattle,0.0861
Starbucks SF,10.0793
```
