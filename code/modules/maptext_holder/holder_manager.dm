GLOBAL_DATUM(maptext_manager, /datum/maptext_holder_manager)

/datum/maptext_holder_manager
	///assoc list of maptext holders by key
	var/list/atom/movable/maptext_holder/holders_by_key = list()
	///assoc nested list of maptext holders keyed to their parent
	var/list/list/atom/movable/maptext_holder/holders_by_parent = list()

/datum/maptext_holder_manager/proc/add_keyed_maptext(key, text, width, height, x, y, atom/movable/maptext_holder/added_holder)
	if(!key)
		return

	if(holders_by_key[key])
		stack_trace("add_keyed_maptext called with an already in use key([key])")
		return holders_by_key[key]

	added_holder ||= new //have to do this here so we dont have a hanging object on no key
	holders_by_key[key] = added_holder
	added_holder.key = key
	set_maptext_values(key, text, width, height, x, y)
	return added_holder

///Set the values of a maptext with an already existing key, if the passed key does not have a value then we simply return
/datum/maptext_holder_manager/proc/set_maptext_values(key, text, width, height, x, y)
	var/atom/movable/maptext_holder/adjusted = holders_by_key[key]
	if(!adjusted)
		return

	if(!isnull(text))
		adjusted.maptext = text
	if(isnum(width))
		adjusted.maptext_width = width
	if(isnum(height))
		adjusted.maptext_height = height
	if(isnum(x))
		adjusted.maptext_x = x
	if(isnum(y))
		adjusted.maptext_y = y
	return adjusted

///Set the parent of of a maptext with an already existing key, we need to ensure key has been set to stop runtimes
/datum/maptext_holder_manager/proc/set_key_parent(key, atom/movable/new_parent)
	var/atom/movable/maptext_holder/adopted = holders_by_key[key]
	if(!adopted)
		return

	var/atom/movable/old_parent = adopted.parent
	if(old_parent)
		clear_parent(adopted, old_parent)

	adopted.parent = new_parent
	if(adopted.parent)
		add_parent(adopted, new_parent)
		new_parent.vis_contents += adopted

///Handle all of the manager side stuff for adding a parent, doesnt effect anything on the child
/datum/maptext_holder_manager/proc/add_parent(atom/movable/maptext_holder/child, atom/parent = child.parent)
	var/list/holder_list = holders_by_parent[parent]
	if(!holder_list) //new parent
		holders_by_parent[parent] = list(child)
		RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(parent_qdel))
		return
	holder_list += child

///Handle all of the manager side stuff for removing a parent, doesnt effect anything on the child
/datum/maptext_holder_manager/proc/clear_parent(atom/movable/maptext_holder/child, atom/parent = child.parent)
	var/list/holder_list = holders_by_parent[parent]
	holder_list -= child
	if(!length(holder_list))
		UnregisterSignal(parent, COMSIG_QDELETING)
		holders_by_parent -= parent

///Called when a registered parent qdels
/datum/maptext_holder_manager/proc/parent_qdel(atom/movable/qdeleted)
	SIGNAL_HANDLER
	var/list/holder_list = holders_by_parent[qdeleted]
	for(var/atom/movable/maptext_holder/holder in holder_list)
		if(holder.qdel_with_parent)
			qdel(holder) //the holders should handle their own cleanup
	holders_by_parent -= qdeleted
	UnregisterSignal(qdeleted, COMSIG_QDELETING)

///Add a NEW managed maptext instance to this atom, this is intended as a creation helper proc, if you want to actually manage the maptext post creation then use the manager
///needs to be on /movable because it uses vis_contents which we cant access on /atom
/*/atom/movable/proc/add_maptext(key, text, width, height, x, y)
	if(!key)
		CRASH("/atom/movable/add_maptext() called without a set key")

	if(isnull(text))
		return

	var/datum/maptext_holder_manager/manager = GLOB.maptext_manager
	if(!manager)
		manager = new
		GLOB.maptext_manager = manager

	var/atom/movable/maptext_holder/new_holder = manager.add_keyed_maptext(key, text, widgth, height, x, y)
	new_holder.parent = src
	manager.add_parent(new_holder, src)
	vis_contents += new_holder
	return new_holder*/
