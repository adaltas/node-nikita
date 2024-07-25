/*
Nikita

This is the main Nikita entry point. It expose a function to initialize a new
Nikita session.
*/

import "@nikitajs/core/register";
import session from "@nikitajs/core/session";

import metadataArgumentToConfig from "@nikitajs/core/plugins/metadata/argument_to_config";
import assertions from "@nikitajs/core/plugins/assertions";
import assertionsExists from "@nikitajs/core/plugins/assertions/exists";
import conditions from "@nikitajs/core/plugins/conditions";
import conditionsExecute from "@nikitajs/core/plugins/conditions/execute";
import conditionsExists from "@nikitajs/core/plugins/conditions/exists";
import conditionsOs from "@nikitajs/core/plugins/conditions/os";
import global from "@nikitajs/core/plugins/global";
import history from "@nikitajs/core/plugins/history";
import magicDollar from "@nikitajs/core/plugins/magic_dollar";
import metadataAudit from "@nikitajs/core/plugins/metadata/audit";
import metadataDebug from "@nikitajs/core/plugins/metadata/debug";
import disabled from "@nikitajs/core/plugins/metadata/disabled";
import metadataExecute from "@nikitajs/core/plugins/metadata/execute";
import metadataHeader from "@nikitajs/core/plugins/metadata/header";
import metadataPosition from "@nikitajs/core/plugins/metadata/position";
import metadataRaw from "@nikitajs/core/plugins/metadata/raw";
import metadataRegister from "@nikitajs/core/plugins/metadata/register";
import metadataRelax from "@nikitajs/core/plugins/metadata/relax";
import metadataRetry from "@nikitajs/core/plugins/metadata/retry";
import metadataSchema from "@nikitajs/core/plugins/metadata/schema";
import metadataTime from "@nikitajs/core/plugins/metadata/time";
import metadataTmpdir from "@nikitajs/core/plugins/metadata/tmpdir";
import metadataUuid from "@nikitajs/core/plugins/metadata/uuid";
import outputLogs from "@nikitajs/core/plugins/output/logs";
import outputStatus from "@nikitajs/core/plugins/output/status";
import pubsub from "@nikitajs/core/plugins/pubsub/index";
import ssh from "@nikitajs/core/plugins/ssh";
import templated from "@nikitajs/core/plugins/templated";
import toolsDig from "@nikitajs/core/plugins/tools/dig";
import toolsEvents from "@nikitajs/core/plugins/tools/events";
import toolsFind from "@nikitajs/core/plugins/tools/find";
import toolsLog from "@nikitajs/core/plugins/tools/log";
import toolsPath from "@nikitajs/core/plugins/tools/path";
import toolsSchema from "@nikitajs/core/plugins/tools/schema";
import toolsWalk from "@nikitajs/core/plugins/tools/walk";

const create = (...args) =>
  session(
    {
      $plugins: [
        metadataArgumentToConfig,
        assertions,
        assertionsExists,
        conditions,
        conditionsExecute,
        conditionsExists,
        conditionsOs,
        global,
        history,
        magicDollar,
        metadataAudit,
        metadataDebug,
        disabled,
        metadataExecute,
        metadataHeader,
        metadataPosition,
        metadataRaw,
        metadataRegister,
        metadataRelax,
        metadataRetry,
        metadataSchema,
        metadataTime,
        metadataTmpdir,
        metadataUuid,
        outputLogs,
        outputStatus,
        pubsub,
        ssh,
        templated,
        toolsDig,
        toolsEvents,
        toolsFind,
        toolsLog,
        toolsPath,
        toolsSchema,
        toolsWalk,
      ],
    },
    ...args,
  );

export default new Proxy(create, {
  get: (_, name) => create()[name],
});
