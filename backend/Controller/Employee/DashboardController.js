const asyncHandler = require('express-async-handler');
const Assignment = require('../../Model/Admin/AssignmentJobControllerModel');
const TimesheetWorklogs = require('../../Model/Admin/TimesheetWorklogModel');
const mongoose = require("mongoose");

// Get start of current week (Sunday)
const getDateRange = () => {
  const today = new Date();
  const startOfWeek = new Date(today);
  startOfWeek.setDate(today.getDate() - today.getDay());
  startOfWeek.setHours(0, 0, 0, 0);
  return { today, startOfWeek };
};

// Parse "HH:MM" into decimal (e.g. "13:30" → 13.5)
const parseHourString = (hourStr) => {
  if (!hourStr) return 0;
  const [h, m] = hourStr.split(':').map(Number);
  return h + (m / 60);
};

// Convert decimal hours back to readable string (e.g. 8.25 → "8.25h")
const formatDecimalHours = (hours) => `${parseFloat(hours.toFixed(2))}h`;

const getEmployeeDashboard = asyncHandler(async (req, res) => {
  const employeeId = req.params.id;

  if (!mongoose.Types.ObjectId.isValid(employeeId)) {
    return res.status(400).json({ success: false, message: "Invalid Employee ID" });
  }

  const { today, startOfWeek } = getDateRange();

  try {
    const assignmentsData = await Assignment.find({ employeeId }).populate("jobs.jobId");

    const assignments = assignmentsData.map(assign => ({
      ...assign.toObject(),
      jobs: assign.jobs.filter(j => j.jobReturnStatus === false)
    }));

    let activeTasks = 0, completedTasks = 0, WaitingApproval = 0, InProgress = 0;

    assignments.forEach(assign => {
      assign.jobs.forEach(jobObj => {
        const job = jobObj.jobId;
        const status = job?.Status?.toLowerCase();
        if (status === 'active') activeTasks++;
        else if (status === 'completed') completedTasks++;
        else if (status === 'waitingapproval') WaitingApproval++;
        else if (status === 'in progress') InProgress++;
      });
    });

    const weeklyLogs = await TimesheetWorklogs.find({
      employeeId,
      date: { $gte: startOfWeek, $lte: today }
    });

    let totalWeeklyHours = 0;
    let todayHours = 0;
    let productiveTime = 0;
    let nonProductiveTime = 0;
    let rawTimeLogs = [];

    weeklyLogs.forEach(log => {
      const logDate = new Date(log.date);
      const isToday = logDate.toDateString() === today.toDateString();

      const parsedTime = parseHourString(log.totalTime);

      // Cap max total per entry to 24h
      const validTime = Math.min(parsedTime, 24);

      if (log.jobId) {
        productiveTime += validTime;
      } else {
        nonProductiveTime += validTime;
      }

      if (isToday) {
        todayHours += validTime;
      }

      totalWeeklyHours += validTime;

      rawTimeLogs.push({
        date: log.date,
        time: log.time,
        overtime: log.overtime,
        totalTime: log.totalTime,
        taskDescription: log.taskDescription,
        status: log.status
      });
    });

    // Targets
    const dailyTarget = 8;
    const weeklyTarget = 48;
    const monthlyTarget = 160;

    const goalPercent = Math.min(100, Math.floor((totalWeeklyHours / weeklyTarget) * 100));
    const remainingHours = Math.max(weeklyTarget - totalWeeklyHours, 0);

    const dashboardData = {
      summary: {
        activeTasks,
        WaitingApproval,
        InProgress,
        completedTasks,
        hoursLogged: formatDecimalHours(totalWeeklyHours),
        performance: goalPercent
      },
      weeklyPerformance: {
        tasksCompleted: completedTasks,
        hoursLogged: formatDecimalHours(totalWeeklyHours),
        goalProgress: goalPercent,
        dueThisWeek: activeTasks,
        compare: {
          tasksCompleted: "↑ 12% vs last week",
          hoursLogged: "↑ 8% vs target",
          dueTasks: "↑ 3 from yesterday"
        }
      },
      todaysPerformance: {
        date: today.toISOString().split("T")[0],
        totalTimeToday: formatDecimalHours(todayHours),
        productiveTime: formatDecimalHours(productiveTime),
        nonProductiveTime: formatDecimalHours(nonProductiveTime),
        target: `${dailyTarget}h`,
        weeklyHours: {
          logged: formatDecimalHours(totalWeeklyHours),
          target: `${weeklyTarget}h`
        },
        goalProgress: {
          percent: goalPercent,
          status:
            goalPercent >= 100 ? "Achieved"
              : goalPercent >= 75 ? "On Track"
              : "Behind",
          remainingHours: formatDecimalHours(remainingHours)
        },
        compare: {
          hoursToday: "↑ 2h vs. yesterday"
        }
      },
      timeLogs: rawTimeLogs
    };

    res.status(200).json({ success: true, data: dashboardData });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch employee dashboard",
      error: error.message
    });
  }
});

module.exports = { getEmployeeDashboard };
