/** @jsx hJSX */
import Cycle from '@cycle/core';
import {makeDOMDriver, hJSX} from '@cycle/dom';
import _ from "lodash";
import moment from "moment";

export default function(x) {
  console.log(x);
  const jobTypes = x.jobTypes.map(x => (
    <tr>
        <td>{x.type}</td>
        <td>
            {x.description}
        </td>
        <td>
            <button className="enqueue-button mdl-button mdl-js-button mdl-button--raised mdl-button--colored" attributes={{"data-name": x.type}}>
                enqueue
            </button>
        </td>
    </tr>
  ));
  const queue = x.queue.map(x => (
    <tr>
        <td>{x.queueJobType}</td>
        <td>{moment(x.queueTime).format()}</td>
    </tr>
  ));
  const running = x.running.map(x => (
    <tr>
        <td>{x.jobType}</td>
        <td>{x.threadId}</td>
        <td>{x.jobId}</td>
        <td>{moment(x.startTime).format()}</td>
    </tr>
  ));
  
  // let flex = {
  //   display: 'flex',
  //   'flex-wrap': 'wrap'
  // };
  // let flexItem = {
  // };
  // let flexItemBreak = {
  //   'flex-basis': '100%'
  // };
  
  return (
    <div className="mdl-layout__content mdl-grid">
        <div className="mdl-cell mdl-cell--12-col">
            <h3>Job Types</h3>
            <table className="mdl-data-table mdl-js-data-table mdl-shadow--2dp">
                <tr><th>name</th><th>description</th><th>action</th></tr>
                {jobTypes}
            </table>
        </div>
        <div className="mdl-cell mdl-cell--4-col" style={({width: '360px'})}>
            <h3>Queue</h3>
            <table className="mdl-data-table mdl-js-data-table mdl-shadow--2dp">
                <tr><th>Type</th><th>Enqueue at</th></tr>
                {queue}
            </table>
        </div>
        <div className="mdl-cell mdl-cell--8-col">
            <h3>Running Jobs</h3>
            <table className="mdl-data-table mdl-js-data-table mdl-shadow--2dp">
                <tr><th>Type</th><th>Thread ID</th><th>Job ID</th><th>Start at</th></tr>
                {running}
            </table>
        </div>
        {/*Snackbar*/}
    </div>
  );
}
