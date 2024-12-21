function pissh {
	ssh ubuntu@fc25:6eaa:827d:3f10:7b03:0000:0000:0001
}

function cmdpissh {
	ssh ubuntu@fc25:6eaa:827d:3f10:7b03:0000:0000:0001 $@
}

function pipullmovies {
	ssh ubuntu@fc25:6eaa:827d:3f10:7b03:0000:0000:0001 'bash /home/ubuntu/Desktop/Commands/UpdateMovies.sh'
}
