var Hours = {
	init: function(start_date) {
		this.hours = [];
		this.start_date = start_date;
		
		this.userMap = {};
		this.taskMap = {};
		this.projectMap = {};
		
		this.filters = {
			'user': null,
			'task': null,
			'project': null
		};
		
		this.currentReport = 'user';
		
		// i.e. week_row = (comment.date - this.start_date) / (day*7)
	},
	
	addHour: function(comment) {
		var record = {
			id: comment.id,
			date: new Date(Date.parse(comment.date)),
			week: comment.week,
			project_id: comment.project_id,
			user_id: comment.user_id,
			task_id: comment.task_id,
			hours: comment.hours
		};
		
		var d = record.date;
		record.key = d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate();
		this.hours.push(record);
	},
	
	addHours: function(comments) {
		comments.forEach(function(comment){
			var record = {
				id: comment.id,
				date: new Date(Date.parse(comment.date)),
				week: comment.week,
				project_id: comment.project_id,
				user_id: comment.user_id,
				task_id: comment.task_id,
				hours: comment.hours
			};
			
			var d = record.date;
			record.key = d.getFullYear() + '-' + d.getMonth() + '-' + d.getDate();
			Hours.hours.push(record);	
		});
	},
	
	setReport: function(report) {
		this.currentReport = report;
		this.update();
	},
	
	update: function() {
		// Run report
		this['report_' + this.currentReport]();
	},
	
	insertCommentBlocks: function(comments, func){
		comments.keys().each(function(key){
			var v = comments.get(key);
			var date = v.date;
			if (date) {
				var calBlock = $("day_" + (date.getMonth()+1) + "_" + date.getDate());
				func(v, v.list, calBlock);
			}
		});
	},
	
	clearCommentBlocks: function(){
		$$('p.hours').each(function(e){e.remove();});
	},
	
	sumByHours: function(field, map) {
		var comments = this.getFilteredComments();
		var weekSum = [{},{},{},{},{},{}];
		var totalSum = {};
		var weekTotal = 0;
		
		comments = this.reduceComments(comments, function(key, values){
			var item = {};
			if (values.length > 0)
				item.date = values[0].date;
			else
				item.date = null;
			
			var list = {};
			values.forEach(function(c){
				// Total day
				var value = list[c.user_id];
				var id = c[field];
				if (value == null || value == undefined)
					list[id] = c.hours;
				else 
					list[id] += c.hours;
				
				// Total week
				var week = Math.floor((c.date - Hours.start_date) / (86400000 * 7));
				var sum = weekSum[week][id];
				if (sum == null || sum == undefined)
					weekSum[week][id] = c.hours;
				else
					weekSum[week][id] += c.hours;
				
				// Total month
				sum = totalSum[id];
				if (sum == null || sum == undefined)
					totalSum[id] = c.hours;
				else
					totalSum[id] += c.hours;
				
				weekTotal += c.hours;
			});
			
			item.list = $H(list);
			return item;
		});
		
		this.clearCommentBlocks();
		
		for (var i=0; i<5; i++) {
			var values = weekSum[i];
			for (var key in values) {
				var code = "<p class=\"hours\">" + map[key] + '=' + values[key] + "hrs</p>";
				$('week_' + i).insert({top:code});
			}
		}
		
		for (var key in totalSum) {
			var code = "<p class=\"hours\">" + map[key] + '=' + totalSum[key] + "hrs</p>";
			$('total_sum').insert({before:code});
		}
		$('total_sum').innerHTML = weekTotal + 'hrs';
		
		// Insert comments into the calendar
		this.insertCommentBlocks(comments, function(v, list, block){
			list.keys().forEach(function(key){
				var code = "<p class=\"hours\">" +  map[key] + "=" + list.get(key) + " hrs</p>";
				block.insert({top:code});
			});
		});
		
		return comments;
	},
	
	report_user: function(){
		return this.sumByHours('user_id', this.userMap);
	},
	
	report_task: function(){
		return this.sumByHours('task_id', this.taskMap);
	},
	
	report_project: function(){
		return this.sumByHours('project_id', this.projectMap);
	},
	
	getFilteredComments: function(){
		var projectFilters = this.filters.project;
		var userFilters = this.filters.user;
		var taskFilters = this.filters.task;
		
		return this.mapComments(this.hours, function(c) {
			if (!Hours.applyFilter(c,
				                  projectFilters,
				                  userFilters,
				                  taskFilters))
				return null;
			
			return {key:c.key, value:c};
		});
	},
	
	mapComments: function(comments, func){
		var set = {};
		comments.each(function(c){
			var res = func(c);
			if (res == null)
				return;
			
			var key = res.key;
			var value = res.value;
			
			var sv = set[key];
			if (sv == null || sv == undefined)
				set[key] = [value];
			else
				sv.push(value);
		});
		
		return $H(set);
	},
	
	reduceComments: function(comments, func){
		var res = $H();
		comments.keys().each(function(key){
			var values = comments.get(key);
			res.set(key, func(key, values));
		});
		return res;
	},
	
	applyFilter: function(hour, projectFilters, userFilters, taskFilters){
		if (projectFilters != null) {
			// Project?
			if (projectFilters.indexOf(hour.project_id) == -1)
				return false;
		}
		
		if (userFilters != null) {
			// User?
			if (userFilters.indexOf(hour.user_id) == -1)
				return false;
		}
		
		if (taskFilters != null) {
			// Task?
			if (taskFilters.indexOf(hour.task_id) == -1)
				return false;
		}
		
		return true;
	}
};