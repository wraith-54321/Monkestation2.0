///Increases the value of each object in the list by 1 and then puts the final object in the starting location of the first object
/proc/cycle_inplace(list/c_list)
	if(!c_list || !c_list.len)
		return
	var/first_obj = c_list[1]
	for(var/i=1, i<c_list.len, ++i)
		c_list[i]=c_list[i+1]
	c_list[c_list.len] = first_obj

/**
 * Scales a range (i.e 1,100) and picks an item from the list based on your passed value
 * i.e in a list with length 4, a 25 in the 1-100 range will give you the 2nd item
 * This assumes your ranges start with 1, I am not good at math and can't do linear scaling
**/
/proc/scale_range_pick(min,max,value,list/L)
	if(!length(L))
		return null
	var/index = 1 + (value * (length(L) - 1)) / (max - min)
	return L[index]
