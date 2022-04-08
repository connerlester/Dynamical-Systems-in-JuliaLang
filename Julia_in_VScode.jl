using #=CairoMakie =#GLMakie
using LaTeXStrings

const N = 250 ## domain side length

"""
Rules Function:
This function dynamically (!) updates the domain "forest" at a given cell (x,y).
    "forest" has dimensions [2,N,N] --> the first being 1=time t and 2=time t+1
"""
function forest!( x , y ;  Pr⚡ =1e-5, Pr🌱 = 7e-3,    🔥 = 2 , 🌲 = 1 , 🪨 = 0  )

    ## Moore neighborhood --> only need to know if one of the neighboors is on fire (ie if the max==🔥)
    neighbor = maximum([forest[1,mod1(x+dx,N),mod1(y+dy,N)] for dx=[-1,0,1],dy=[-1,0,1]])

    cell = forest[1,x,y] ##cell to analyze at time t (1st index=1)

    ## RULES: 
    if cell == 🔥 ## if youre a burning tree
        cell = 🪨 ## you burn out

    elseif neighbor == 🔥 && cell == 🌲 ## any neighbors burning and youre a tree
        cell = 🔥 ## you start to burn

    elseif cell == 🌲 && Pr⚡ > rand() ## if youre a tree, you get struck by lighning with probability Pr⚡
        cell = 🔥

    elseif cell == 🪨 && Pr🌱 > rand() ## if youre dirt, you grow a tree with probability Pr🌱
        cell = 🌲
    end

    forest[2,x,y] = cell ## update the domain at t+1 (1st index=2)

    nothing #return nothing
end

"""
This function loops over all cells in "forest" and dynamically updates the domain
    Each call of this function is a time step
"""
function step!()
    for x ∈ 1:N
        for y ∈ 1:N
            forest!(x,y) ## update domain at t+1
        end
    end
    forest[1,:,:] = forest[2,:,:] # set updated domain (t+1) to current time (t)

    nothing #return nothing
end

    
## INIT DOMAIN
forest = zeros(2,N,N); ## init forest domain with no trees in this case... [2,N,N] -> [(t,t+1), (area)]

## create a "heatmap" to be updated in loop: "fire" is an Observable() that that can be actively updated
## -- note that this will create a pop-up window
fig,ax,fire = heatmap( forest[1,:,:],  ##<- plotting current time (1st index=1)
        colorrange=(0,2),colormap=cgrad([:darkslategrey,:forestgreen,:firebrick], 3, categorical=true)) ## colors

# color bars
cbar = Colorbar(fig[1, 2],fire,labelsize=40,ticklabelsize=20)
cbar.ticks = ([1/3, 1, 1+2/3], ["Ash","Tree", "Fire"])



#This time loop updates the domain and also updates the heatmap plot
for time = 1:4e2
    step!() ##loop over domain and update cells via the rules in forest!()

    fire[3][] = forest[1,:,:] ## update the plot with new forest domain

    yield() ## some scheduling thing to update the plot
end
## to stop the loop: Ctrl+C in REPL


record(fig, "Forest_Fire.mp4", 1:5e2; ## record loop above
framerate=20) do next_t
    step!() 
    fire[3][] = forest[1,:,:]
end