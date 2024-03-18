// Register actions from Nikita packages
import "@nikitajs/db/register";
import "@nikitajs/docker/register";
import "@nikitajs/file/register";
import "@nikitajs/ipa/register";
import "@nikitajs/java/register";
import "@nikitajs/krb5/register";
import "@nikitajs/ldap/register";
import "@nikitajs/log/register";
import "@nikitajs/incus/register";
import "@nikitajs/network/register";
import "@nikitajs/service/register";
import "@nikitajs/system/register";
import "@nikitajs/tools/register";
// Expose the Nikita core engine
import nikita from "@nikitajs/core";

export default nikita;
